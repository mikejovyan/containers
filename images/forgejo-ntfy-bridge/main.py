#!/usr/bin/env python3
"""Transparent relay: the raw Forgejo webhook body is forwarded unmodified
to NTFY_URL/NTFY_TOPIC(?template=NTFY_TEMPLATE) - ntfy's own built-in
template engine does all the formatting, not this bridge."""

import fnmatch
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def split_csv(s):
    return [p.strip() for p in s.split(",") if p.strip()]


def list_allowed(allowed, ignored, value):
    # Standard allow/deny-list precedence (the same "explicit deny always
    # wins" convention used by AWS IAM, most firewalls, etc.): a value
    # matching ignored is always rejected; otherwise, if an allow-list is
    # configured, only values in it pass.
    if value in ignored:
        return False
    return not (allowed and value not in allowed)


def parse_event_filters(s):
    # Entries are "event_type" (any action) or "event_type:action" (e.g.
    # "pull_request:closed"). ":" is used (not "_") because event type names
    # already contain underscores (e.g. "issue_comment",
    # "pull_request_review_approved"), which would make a concatenated name
    # ambiguous to split back apart.
    filters = []
    for entry in split_csv(s):
        event_type, _, action = entry.partition(":")
        filters.append((event_type, action))
    return filters


def event_allowed(filters, event_type, data):
    # No filters configured = allow everything (default behavior).
    if not filters:
        return True
    action = data.get("action")
    if not isinstance(action, str):
        action = ""
    for f_type, f_action in filters:
        if f_type != event_type:
            continue
        if f_action == "" or f_action == action:
            return True
    return False


def strip_field(data, path):
    # Deletes the field at a dotted path (e.g. "pull_request.base.repo")
    # from data, if present. A missing path, or one that doesn't resolve to
    # nested objects, is silently a no-op rather than an error.
    segments = path.split(".")
    cur = data
    for seg in segments[:-1]:
        nxt = cur.get(seg) if isinstance(cur, dict) else None
        if not isinstance(nxt, dict):
            return
        cur = nxt
    if isinstance(cur, dict):
        cur.pop(segments[-1], None)


def payload_branch(data):
    # Mirrors Forgejo's own getPayloadBranch (services/webhook/webhook.go):
    # for a pull request, the target (base) branch; for a raw ref event
    # (push/create/delete), the ref with its "refs/heads/" prefix stripped.
    # Returns "" if the payload has no associated branch at all (e.g. an
    # issue), matching Forgejo's own "branch filter has no effect" comment.
    pr = data.get("pull_request")
    if isinstance(pr, dict):
        base = pr.get("base")
        if isinstance(base, dict) and isinstance(base.get("ref"), str):
            return base["ref"]
    ref = data.get("ref")
    prefix = "refs/heads/"
    if isinstance(ref, str) and ref.startswith(prefix):
        return ref[len(prefix) :]
    return ""


def branch_matches(pattern, branch):
    # Mirrors Forgejo's own checkBranch (services/webhook/webhook.go): an
    # empty pattern or "*" matches everything; otherwise it's a glob match.
    if pattern in ("", "*"):
        return True
    return fnmatch.fnmatchcase(branch, pattern)


NTFY_PORT = os.environ.get("NTFY_PORT") or "8080"
_ntfy_base = os.environ.get("NTFY_URL", "").rstrip("/")
_ntfy_topic = os.environ.get("NTFY_TOPIC", "")
_ntfy_template = os.environ.get("NTFY_TEMPLATE", "")

NTFY_URL = f"{_ntfy_base}/{_ntfy_topic}"
if _ntfy_template:
    NTFY_URL += "?template=" + urllib.parse.quote(_ntfy_template, safe="")

ALLOWED_EVENTS = parse_event_filters(os.environ.get("NTFY_ALLOWED_EVENTS", ""))
STRIP_FIELDS = split_csv(os.environ.get("NTFY_STRIP_FIELDS", ""))
BRANCH_FILTER = os.environ.get("NTFY_BRANCH_FILTER", "")
ALLOWED_USERS = split_csv(os.environ.get("NTFY_ALLOWED_USERS", ""))
IGNORED_USERS = split_csv(os.environ.get("NTFY_IGNORED_USERS", ""))
ALLOWED_REPOS = split_csv(os.environ.get("NTFY_ALLOWED_REPOS", ""))
IGNORED_REPOS = split_csv(os.environ.get("NTFY_IGNORED_REPOS", ""))


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        sys.stderr.write(f"{self.address_string()} - {format % args}\n")

    def _no_content(self):
        self.send_response(204)
        self.end_headers()

    def _error(self, code, message):
        self.send_response(code)
        self.end_headers()
        self.wfile.write(message.encode())

    def do_GET(self):
        if self.path == "/healthz":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else b""

        event = self.headers.get("X-Forgejo-Event-Type", "")

        # Only decode the payload if something actually needs to inspect or
        # modify it - a plain forward (no filters/strips configured) stays a
        # pure byte passthrough, same as before.
        needs_valid_json = bool(
            ALLOWED_EVENTS
            or BRANCH_FILTER
            or ALLOWED_USERS
            or IGNORED_USERS
            or ALLOWED_REPOS
            or IGNORED_REPOS
        )
        needs_decode = needs_valid_json or bool(STRIP_FIELDS)

        if needs_decode:
            data = None
            try:
                parsed = json.loads(body)
                if isinstance(parsed, dict):
                    data = parsed
            except ValueError:
                pass

            if data is None:
                if needs_valid_json:
                    print(f'dropping event "{event}": payload not valid JSON')
                    self._no_content()
                    return
            else:
                if not event_allowed(ALLOWED_EVENTS, event, data):
                    print(f'dropping event "{event}": not in NTFY_ALLOWED_EVENTS')
                    self._no_content()
                    return

                branch = payload_branch(data)
                if branch and not branch_matches(BRANCH_FILTER, branch):
                    print(
                        f'dropping event "{event}": branch "{branch}" '
                        f'doesn\'t match NTFY_BRANCH_FILTER "{BRANCH_FILTER}"'
                    )
                    self._no_content()
                    return

                sender = data.get("sender")
                login = sender.get("login") if isinstance(sender, dict) else None
                login = login if isinstance(login, str) else ""
                if not list_allowed(ALLOWED_USERS, IGNORED_USERS, login):
                    print(
                        f'dropping event "{event}": sender "{login}" filtered '
                        f"by NTFY_ALLOWED_USERS/NTFY_IGNORED_USERS"
                    )
                    self._no_content()
                    return

                repo = data.get("repository")
                repo_full_name = (
                    repo.get("full_name") if isinstance(repo, dict) else None
                )
                repo_full_name = (
                    repo_full_name if isinstance(repo_full_name, str) else ""
                )
                if not list_allowed(ALLOWED_REPOS, IGNORED_REPOS, repo_full_name):
                    print(
                        f'dropping event "{event}": repository "{repo_full_name}" '
                        f"filtered by NTFY_ALLOWED_REPOS/NTFY_IGNORED_REPOS"
                    )
                    self._no_content()
                    return

                for path in STRIP_FIELDS:
                    strip_field(data, path)
                body = json.dumps(data).encode()

        req = urllib.request.Request(NTFY_URL, data=body, method="POST")
        req.add_header("Content-Type", "application/json")
        # Forward whatever Authorization Forgejo sent on this delivery - set
        # it as the webhook's "Authorization Header" in Forgejo, not as a
        # separate secret held by this bridge.
        auth = self.headers.get("Authorization")
        if auth:
            req.add_header("Authorization", auth)

        try:
            with urllib.request.urlopen(req) as resp:
                status = resp.status
                resp_body = resp.read()
        except urllib.error.HTTPError as e:
            status = e.code
            resp_body = e.read()
        except urllib.error.URLError as e:
            print(f"error publishing to ntfy: {e}")
            self._error(502, "failed to publish notification")
            return

        if status // 100 != 2:
            print(f"ntfy returned {status}: {resp_body!r}")
            self._error(502, "failed to publish notification")
            return

        self.send_response(200)
        self.end_headers()


def main():
    server = ThreadingHTTPServer(("", int(NTFY_PORT)), Handler)
    print(f"listening on :{NTFY_PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
