#!/bin/sh
set -eu

echo "[entrypoint] Starting VS Code CLI container"

# Run fixuid if available
if command -v fixuid >/dev/null 2>&1; then
  echo "[entrypoint] Running fixuid..."
  fixuid
fi

# Provide default values safely using parameter expansion
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
CLI_DATA_DIR="${CLI_DATA_DIR:-/home/coder/.vscode/cli-data}"
SERVER_DATA_DIR="${SERVER_DATA_DIR:-/home/coder/.vscode/server-data}"

echo "[entrypoint] Using host: $HOST"
echo "[entrypoint] Using port: $PORT"
echo "[entrypoint] Using CLI data dir: $CLI_DATA_DIR"
echo "[entrypoint] Using server data dir: $SERVER_DATA_DIR"

# Base command with license acceptance
CMD="code serve-web --accept-server-license-terms"
CMD="$CMD --host $HOST --port $PORT"
CMD="$CMD --cli-data-dir $CLI_DATA_DIR"
CMD="$CMD --server-data-dir $SERVER_DATA_DIR"

# Check if TOKEN environment variable is set
if [ -z "${TOKEN:-}" ]; then
  echo "[entrypoint] No TOKEN provided, starting without token"
  CMD="$CMD --without-connection-token"
else
  echo "[entrypoint] Starting with token: $TOKEN"
  CMD="$CMD --connection-token $TOKEN"
fi

# Check if TOKEN_FILE environment variable is set (overrides TOKEN if both are set)
if [ -n "${TOKEN_FILE:-}" ]; then
  echo "[entrypoint] Using token file: $TOKEN_FILE"
  CMD="$CMD --connection-token-file $TOKEN_FILE"
fi


# Verbose mode and log level
if [ "${VERBOSE:-}" = "true" ]; then
  echo "[entrypoint] Running in verbose mode"
  CMD="$CMD --verbose"
fi

if [ "${LOG_LEVEL:-}" ]; then
  echo "[entrypoint] Using log level: $LOG_LEVEL"
  CMD="$CMD --log $LOG_LEVEL"
fi

echo "[entrypoint] Final command: $CMD"

# Execute
exec $CMD
