#!/bin/sh

echo "[entrypoint] Starting VS Code CLI container"

CMD="code serve-web"

HOST="${HOST:-0.0.0.0}"
CMD="$CMD --host $HOST"

if [ -n "$SOCKET_PATH" ]; then
  CMD="$CMD --socket-path $SOCKET_PATH"
fi

PORT="${PORT:-8000}"
CMD="$CMD --port $PORT"

if [ -n "$TOKEN" ]; then
  CMD="$CMD --connection-token $TOKEN"
fi

if [ -n "$TOKEN_FILE" ]; then
  CMD="$CMD --connection-token-file $TOKEN_FILE"
fi

if [ -z "$TOKEN" ] && [ -z "$TOKEN_FILE" ]; then
  CMD="$CMD --without-connection-token"
fi

CMD="$CMD --accept-server-license-terms"

if [ -n "$SERVER_BASE_PATH" ]; then
  CMD="$CMD --server-base-path $SERVER_BASE_PATH"
fi

if [ -n "$SERVER_DATA_DIR" ]; then
  CMD="$CMD --server-data-dir $SERVER_DATA_DIR"
fi

if [ -n "$DEFAULT_FOLDER" ]; then
  CMD="$CMD --default-folder $DEFAULT_FOLDER"
fi

if [ -n "$DEFAULT_WORKSPACE" ]; then
  CMD="$CMD --default-workspace $DEFAULT_WORKSPACE"
fi

if [ -n "$DISABLE_TELEMETRY" ] && [ "$DISABLE_TELEMETRY" = "true" ]; then
  CMD="$CMD --disable-telemetry"
fi

# Pin server version to match the installed CLI
CMD="$CMD --commit-id $(code --version | grep -oE '[a-f0-9]{40}')"

if [ -n "$CLI_DATA_DIR" ]; then
  CMD="$CMD --cli-data-dir $CLI_DATA_DIR"
fi

if [ -n "$VERBOSE" ] && [ "$VERBOSE" = "true" ]; then
  CMD="$CMD --verbose"
fi

if [ -n "$LOG_LEVEL" ]; then
  CMD="$CMD --log $LOG_LEVEL"
fi

for f in "$HOME/.app-start"/*.sh; do
  [ -f "$f" ] || continue
  echo "[entrypoint] sourcing ${f##*/}"
  . "$f"
done

unset HOST SOCKET_PATH PORT TOKEN TOKEN_FILE SERVER_BASE_PATH SERVER_DATA_DIR \
      DEFAULT_FOLDER DEFAULT_WORKSPACE DISABLE_TELEMETRY CLI_DATA_DIR VERBOSE LOG_LEVEL

echo "Executing: $CMD"
exec $CMD
