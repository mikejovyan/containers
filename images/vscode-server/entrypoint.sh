#!/bin/sh
set -e

echo "[entrypoint] Starting VS Code CLI container"

# give an unrecognized uid (e.g. --user <uid>:0) a resolvable username
if ! whoami >/dev/null 2>&1; then
	if [ -w /etc/passwd ]; then
		echo "[entrypoint] no /etc/passwd entry for uid $(id -u); adding one"
		echo "${APP_USER}:x:$(id -u):$(id -g):,,,:${HOME}:/bin/bash" >>/etc/passwd
	else
		echo "[entrypoint] warning: no /etc/passwd entry for uid $(id -u) and /etc/passwd isn't writable - try --user <uid>:0" >&2
	fi
fi

set -- code serve-web --host "${HOST:-0.0.0.0}"

[ -n "$SOCKET_PATH" ] && set -- "$@" --socket-path "$SOCKET_PATH"

set -- "$@" --port "${PORT:-8000}"

[ -n "$TOKEN" ] && set -- "$@" --connection-token "$TOKEN"
[ -n "$TOKEN_FILE" ] && set -- "$@" --connection-token-file "$TOKEN_FILE"
[ -z "$TOKEN" ] && [ -z "$TOKEN_FILE" ] && set -- "$@" --without-connection-token

set -- "$@" --accept-server-license-terms

[ -n "$SERVER_BASE_PATH" ] && set -- "$@" --server-base-path "$SERVER_BASE_PATH"
[ -n "$SERVER_DATA_DIR" ] && set -- "$@" --server-data-dir "$SERVER_DATA_DIR"
[ -n "$DEFAULT_FOLDER" ] && set -- "$@" --default-folder "$DEFAULT_FOLDER"
[ -n "$DEFAULT_WORKSPACE" ] && set -- "$@" --default-workspace "$DEFAULT_WORKSPACE"

[ "$DISABLE_TELEMETRY" = "true" ] && set -- "$@" --disable-telemetry

# Pin server version to match the installed CLI
set -- "$@" --commit-id "$(code --version | grep -oE '[a-f0-9]{40}')"

# GLOBAL OPTIONS per --help, not specific to serve-web
[ -n "$CLI_DATA_DIR" ] && set -- "$@" --cli-data-dir "$CLI_DATA_DIR"

[ "$VERBOSE" = "true" ] && set -- "$@" --verbose

[ -n "$LOG_LEVEL" ] && set -- "$@" --log "$LOG_LEVEL"

# a failing hook shouldn't block startup - log it and keep going
set +e
for f in "$HOME/.app-start"/*.sh; do
	[ -f "$f" ] || continue
	echo "[entrypoint] sourcing ${f##*/}"
	. "$f"
	hook_rc=$?
	[ "$hook_rc" -ne 0 ] && echo "[entrypoint] ${f##*/} failed (exit $hook_rc), continuing" >&2
done
set -e
unset hook_rc

unset HOST SOCKET_PATH PORT TOKEN TOKEN_FILE SERVER_BASE_PATH SERVER_DATA_DIR \
	DEFAULT_FOLDER DEFAULT_WORKSPACE DISABLE_TELEMETRY CLI_DATA_DIR VERBOSE LOG_LEVEL

echo "Executing: $*"
exec "$@"
