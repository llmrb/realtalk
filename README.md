## About

Relay is an interactive [llm.rb](https://github.com/llmrb/llm.rb#readme)
application built with HTMX, Roda, Falcon, and WebSockets. It serves
as both a demo of [llm.rb](https://github.com/llmrb/llm.rb#readme) and
an example of a Ruby-first architecture that keeps JavaScript light
while still supporting background workers and a database-backed app.

Relay serves as a reference implementation for building real-time,
tool-enabled LLM applications with llm.rb in a production-style
environment.

## Features

- 🌊 Streaming chat over WebSockets
- 🛠️ Custom tool support via [app/tools/](app/tools)
- 🖼️ Sample image-generation tool in [create_image.rb](./app/tools/create_image.rb)
- ⚙️ Rack application built with Falcon, Roda, and async-websocket
- 🗃️ Sequel with built-in migrations
- 🧵 Sidekiq workers for background jobs
- 🧰 Built-in task monitor that that starts and supervises the full development environment (web, workers, assets)

## Quick start

**Setup**

Redis is required for Sidekiq support.
SQLite is required for database support.

    bundle install
    bundle exec rake db:migrate
    bundle exec rake dev:start

**Secrets**

Set your secrets in `.env`:

```sh
OPENAI_SECRET=...
GOOGLE_SECRET=...
ANTHROPIC_SECRET=...
DEEPSEEK_SECRET=...
XAI_SECRET=...
REDIS_URL=
```
## Architecture

The architecture is intentionally simple. HTMX keeps the client light,
while server-rendered HTML keeps the application comfortable for
Ruby-focused developers. Background work is handled with Sidekiq, and
development processes are coordinated by Relay's task monitor.

Some important notes:

* The app boots from `app/init.rb`, which sets up the database,
  autoloading, and application initialization.
* HTTP routing is handled by Roda, with templates rendered from
  `app/views` and static assets served from `public/`.
* Webpack builds the JavaScript and CSS assets from `app/assets`.

The codebase is organized by responsibility:

- `app/init` contains boot and framework setup
- `app/tools` contains tools
- `app/prompts` contains system prompt
- `app/models` contains Sequel models
- `app/routes` contains route classes and WebSocket handlers
- `app/views` contains HTML templates and partials
- `app/workers` contains Sidekiq workers
- `db/` contains database configuration and migrations
- `tasks/` contains rake tasks for development, assets, and database work
- `lib/relay` contains support code like the task monitor

## Sources

* [GitHub.com](https://github.com/llmrb/realtalk)
* [GitLab.com](https://gitlab.com/llmrb/realtalk)
* [Codeberg.org](https://codeberg.org/llmrb/realtalk)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
