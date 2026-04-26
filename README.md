## About

Relay is a production-style, self-hostable LLM environment built on
[llm.rb](https://github.com/llmrb/llm.rb#readme). It gives you one
place to work with providers, models, tools, MCP servers, attachments,
saved contexts, and streaming conversations, and serves both as a
usable application and as a reference implementation for building
products on top of [llm.rb](https://github.com/llmrb/llm.rb#readme).

## Screenshot

![Relay screenshot](./screenshot.png)

## Built with llm.rb

#### Built on llm.rb
Relay is meant to show what
[llm.rb](https://github.com/llmrb/llm.rb#readme) can power in a real
application:

- multi-provider conversational products
- persistent contexts and long-lived sessions
- built-in tools and MCP-backed capabilities
- streaming interfaces
- cost and context-window visibility

#### From runtime to product

| [llm.rb](https://github.com/llmrb/llm.rb#readme) capability | How Relay uses it |
| --- | --- |
| `LLM::Context` | Saved conversations and long-lived chat sessions |
| Provider abstraction | Provider and model switching in the UI |
| Tools runtime | Built-in tools and local tool execution |
| MCP integration | External capability and server integration |
| Streaming/context execution | Live streamed responses over the chat UI |
| Cost and context tracking | Sidebar and status indicators for usage and context budget |

#### Why Relay matters

Relay demonstrates that
[llm.rb](https://github.com/llmrb/llm.rb#readme) can support:

- multi-provider conversational applications
- persistent session and context management
- user-visible tools and MCP servers
- streaming user interfaces
- long-context workflows
- operational features like cost and context-window tracking

## Why use Relay

Relay is a good fit if you want to:

- use a self-hosted workspace for multi-provider LLM work
- connect models to local tools and MCP servers
- keep long-lived conversations with saved contexts
- compare providers and models in one interface
- fork a real application as the base for your own
  [llm.rb](https://github.com/llmrb/llm.rb#readme) product

## Quick start

If you just want Relay running locally, this is the shortest path.

**Requirements**

- Ruby
- Node.js
- Webpack
- SQLite

**1. Install dependencies**

```sh
bundle install
```

**2. Configure secrets**

Create a `.env` file:

```sh
OPENAI_SECRET=...
GOOGLE_SECRET=...
ANTHROPIC_SECRET=...
DEEPSEEK_SECRET=...
XAI_SECRET=...
SESSION_SECRET=...
REDIS_URL=
```

You only need provider secrets for the providers you plan to use.

**3. Set up the database**

```sh
bundle exec rake db:setup
bundle exec rake db:seed
```

The seed creates a default local user:

- email: `0x1eef@hardenedbsd.org`
- password: `relay`

Change the seeded values in [db/seeds.rb](./db/seeds.rb) first if you
do not want those defaults.

**4. Start Relay**

```sh
bundle exec rake dev:start
```

Then open Relay in your browser and sign in with the seeded account.

During development, Relay enables Zeitwerk reloading and refreshes
autoloaded constants between requests, so changes under `app/` are
picked up without restarting the web server.

## Features

### Workspace

- Streaming chat over WebSockets with server-rendered updates
- Multiple provider support: OpenAI, Google, Anthropic, DeepSeek, and xAI
- Saved chat contexts with provider-aware switching and new-context creation
- Attachment support for providers that accept local files through
  [`llm.rb`](https://github.com/llmrb/llm.rb#readme)
- Built-in tool support plus automatic loading of custom tools from [app/tools/](app/tools)
- Optional MCP server integration via [app/config/mcp.yml.sample](app/config/mcp.yml.sample)
- Session-backed sign-in and per-user persistent context
- A jukebox sidebar with tool-driven playlist management

### Platform

- Rack application built with Falcon, Roda, and async-websocket
- Sequel models and migrations for application state
- Sidekiq workers for background jobs
- A built-in task monitor for the local development stack: web, workers, and assets
- Session support through Roda's session plugin
- In-memory shared state via `Relay.cache`
- Automatic `.env` loading during boot
- Zeitwerk hot reloading in development

## For builders

Relay is both a usable product and a reference implementation. If you
want the internal layout, routing model, concerns, boot sequence, and
test structure, see [resources/architecture.md](./resources/architecture.md).

## Customization

**Tools**

Relay ships with built-in tools in [`app/tools/`](app/tools):

- [`create_image.rb`](./app/tools/create_image.rb) generates images
- [`relay_knowledge.rb`](./app/tools/relay_knowledge.rb) exposes project documentation
- [`juke_box.rb`](./app/tools/juke_box.rb) reads from the built-in playlist
- [`add_song.rb`](./app/tools/add_song.rb) adds songs to the jukebox playlist
- [`remove_song.rb`](./app/tools/remove_song.rb) removes songs from the jukebox playlist
- [`apropos.rb`](./app/tools/apropos.rb) searches FreeBSD man pages with `apropos`

These tools serve as examples of how to extend Relay's behavior. They
show common patterns such as calling external providers, editing local
application data, returning documentation-backed knowledge, invoking
system commands, and rendering structured tool output in the interface.

To add your own behavior, create additional tools under `app/tools/`.
Relay loads registered tools automatically, so new tools become
available to the model alongside the built-in ones.

**MCP**

Relay reads MCP server configuration from `app/config/mcp.yml` when the
file is present. Use [`app/config/mcp.yml.sample`](app/config/mcp.yml.sample)
as the starting point.

You can add your own stdio MCP servers by appending entries under
`stdio`. Each server entry includes:

- `name`: the display name shown in the UI
- `description`: a short explanation of what the server provides
- `config`: the stdio launch configuration Relay passes to `LLM.mcp`

The `config` object supports:

- `argv`: the command and arguments used to start the MCP server
- `env`: environment variables passed to the process
- `cwd`: optional working directory for the process

Example:

```yml
stdio:
  - name: GitHub
    description: GitHub's MCP server
    config:
      argv: ["github-mcp-server", "stdio"]
      env:
        GITHUB_PERSONAL_ACCESS_TOKEN: <YOUR_TOKEN>
```

For local or self-hosted Forgejo and Gitea instances, you can use an MCP
server such as [`forgejo-mcp`](https://github.com/Sqcows/forgejo-mcp)
and point it at your local server URL:

```yml
stdio:
  - name: Forgejo
    description: Forgejo/Gitea MCP server
    config:
      argv: ["npx", "@ric_/forgejo-mcp"]
      env:
        FORGEJO_URL: http://localhost:3000
        FORGEJO_TOKEN: <YOUR_TOKEN>
```

Setup:

1. Install the MCP server binary you want to use, for example
   `github-mcp-server` or `npx @ric_/forgejo-mcp`.
2. Copy `app/config/mcp.yml.sample` to `app/config/mcp.yml`.
3. Fill in any required environment variables such as API tokens.
4. Restart Relay.

Once configured, Relay starts the MCP servers for the chat session and
adds their tools to the available tool list. If `app/config/mcp.yml`
is absent, Relay starts without any MCP servers.

## Sources

* [GitHub.com](https://github.com/llmrb/relay)
* [GitLab.com](https://gitlab.com/llmrb/relay)
* [Codeberg.org](https://codeberg.org/llmrb/relay)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
