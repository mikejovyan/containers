# Usage

Mounts the current directory as `/home/coder/Projects`, your own `.config`/`.vscode`/`.app-start`, and forwards your UID/GID so files come out owned by you on the host:

```sh
docker run -d --name vscode-server \
  -p 127.0.0.1:8000:8000 \
  -v "$HOME/.config:/home/coder/.config" \
  -v "$HOME/.vscode:/home/coder/.vscode" \
  -v "$HOME/.app-start:/home/coder/.app-start" \
  -v "$PWD:/home/coder/Projects" \
  -u "$(id -u):$(id -g)" \
  vscode-server:latest
```

# Configuration

## Environment variables

All of these are read by [`entrypoint.sh`](entrypoint.sh) and map directly to `code serve-web` flags.

| Variable | Description | Default |
|---|---|---|
| `HOST` | Address to bind to | `0.0.0.0` |
| `PORT` | Port to listen on | `8000` |
| `SOCKET_PATH` | Additional Unix socket to listen on | - |
| `TOKEN` | Connection token required to connect | - |
| `TOKEN_FILE` | File containing the connection token, instead of `TOKEN` | - |
| `SERVER_BASE_PATH` | URL path prefix to serve the editor under | - |
| `SERVER_DATA_DIR` | Directory for server-side data | - |
| `DEFAULT_FOLDER` | Folder to open when none is given in the browser URL | - |
| `DEFAULT_WORKSPACE` | `.code-workspace` file to open when none is given in the browser URL | - |
| `DISABLE_TELEMETRY` | Disable telemetry | `false` |
| `CLI_DATA_DIR` | Directory for the `code` CLI's own metadata | - |
| `VERBOSE` | Verbose CLI output | `false` |
| `LOG_LEVEL` | `trace`, `debug`, `info`, `warn`, `error`, `critical`, `off` | - |

Notes:

- If neither `TOKEN` nor `TOKEN_FILE` is set, the server starts with `--without-connection-token` — fine on a `127.0.0.1`-only published port behind your own auth, not fine on an open network. With a token set, open `http://<host>:<port>?tkn=<token>` to connect without being prompted for it separately.

## Build arguments

| Argument | Description | Default |
|---|---|---|
| `APP_USER` | Non-root user name | `coder` |
| `APP_UID` | UID of `APP_USER` | `1000` |
| `APP_GID` | GID of `APP_USER`'s own group | `1000` |
| `APP_VERSION` | VS Code CLI version to install | current `code` CLI version |
