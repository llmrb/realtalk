## About

Relay is a small chat app built with [llm.rb](https://github.com/llmrb/llm.rb).
It demonstrates streaming over WebSockets, tool calls, image generation,
provider switching, model selection, and a small Sequel-backed
server. The app renders HTML from `app/views`, and the Rack
server lives under `app`. See the [Screencast](#screencast) for a
demo.

Enjoy :)

## Screencast

[![Watch the screencast](https://img.youtube.com/vi/fOvAFq7ITiE/maxresdefault.jpg)](https://youtu.be/fOvAFq7ITiE)

Watch the screencast on [YouTube](https://youtu.be/fOvAFq7ITiE).

## Features

- ⚙️ Rack application built with Falcon, Roda, and async-websocket
- 🗃️ Sequel with built-in migrations
- 🌊 Streaming chat over WebSockets
- 🔀 Switch providers: OpenAI, Gemini, Anthropic, xAI and DeepSeek
- 🧠 Switch models: varies by provider
- 🛠️ Add your own tools: see [app/tools/](app/tools)
- 🖼️ Image generation via [create_image.rb](./app/tools/create_image.rb) - requires Gemini, OpenAI or xAI but works with any provider

## Usage

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

**Packages**

Install Ruby gems:

```sh
bundle install
```

**Database**

Create a migration:

```sh
bundle exec rake "db:new_migration[create_widgets]"
```

Run migrations:

```sh
bundle exec rake db:migrate
```

Models live in `app/models`, and the app boots Sequel from
`db/config.yml`.

The SQLite database files under `db/` are local-only and ignored by git.

**Server Layout**

- `app/models` contains Sequel models
- `app/routes` contains the Roda-facing endpoints
- `app/tools` contains LLM tool classes
- `app/views` contains the HTML templates and HTMX fragments
- `app/init/router.rb` dispatches `/api/models`, `/api/tools`, and
  `/api/ws`
- `config.ru` serves generated images and static images from `public/`
  and boots the router

**Development**

Run the server and Sidekiq in separate shells:

```sh
bundle exec rake dev:server
bundle exec rake dev:sidekiq
```

Then open `http://localhost:9292`. The Ruby server serves the HTML
pages, `/api/models`, `/api/tools`, `/api/ws`, and generated images
from `/g`.

Or run both processes together with Foreman:

```sh
bundle exec foreman start
```

## Sources

* [GitHub.com](https://github.com/llmrb/realtalk)
* [GitLab.com](https://gitlab.com/llmrb/realtalk)
* [Codeberg.org](https://codeberg.org/llmrb/realtalk)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
