# Connecting Google Slides

Read this when Phase 0 found neither a Slides MCP server nor a Drive connector,
or when a route fails with an auth error.

## Option 1 — Official Google Slides MCP server (full read/write)

Google ships a **remote** MCP server for the Slides API. Nothing to install.

| | |
| --- | --- |
| Server URL | `https://slidesmcp.googleapis.com/mcp/v1` |
| Tools | `read_presentation`, `update_presentation` |
| Auth | OAuth 2.0 — client ID + secret from Google Cloud Console |
| Status | Google Workspace **Developer Preview** — enrollment required, surface may change |
| Docs | https://developers.google.com/workspace/slides/api/guides/configure-mcp-server |

Config shape:

```json
{
  "serverUrl": "https://slidesmcp.googleapis.com/mcp/v1",
  "oauth": {
    "clientId": "OAUTH_CLIENT_ID",
    "clientSecret": "OAUTH_CLIENT_SECRET"
  }
}
```

What to tell the user: they need to enroll in the Workspace Developer Preview
Program, create an OAuth 2.0 client in Cloud Console, and add the server to their
MCP configuration. This cannot be done from inside a session — it is a settings
change on their side.

## Option 2 — Google Drive connector (create-only)

If the user has the Google Drive connector enabled on claude.ai, Route B works
with no further setup. Confirm by looking for a `create_file` tool.

This route creates decks but **cannot edit them afterwards** — see the Route B
limitation in `SKILL.md`.

## Option 3 — Third-party Slides MCP servers

Open-source and hosted alternatives exist, typically exposing
`create_presentation`, `get_presentation` and `batch_update_presentation`:

- https://github.com/matteoantoci/google-slides-mcp (open source, self-hosted)
- Hosted wrappers from Composio, Merge and Activepieces

These are not vetted here. If the user adopts one, check what OAuth scopes it
requests before connecting it to a Drive that holds real work.

## Authorization is the user's to do

If a server is configured but unauthorized, an agent cannot complete the OAuth
flow on the user's behalf. Say the connector needs authorizing — via claude.ai
connector settings, or `claude mcp` / `/mcp` in an interactive session — and stop.
Never ask the user to paste tokens, authorization codes, or callback URLs into
the conversation.
