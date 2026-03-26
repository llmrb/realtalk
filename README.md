# Relay

Relay is a Rack-based web application that provides an interface for interacting with LLM models through a unified API.

## Features

- WebSocket support for real-time communication
- Multiple LLM provider support
- Session-based authentication
- Tool integration for extended functionality
- Asset management and compilation
- Database persistence with Sequel

## Getting Started

### Prerequisites

- Ruby 3.0+
- Bundler
- SQLite3

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/llmrb/relay.git
   cd relay
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rake db:migrate
   ```

4. Start the development server:
   ```bash
   rake dev
   ```

5. Visit `http://localhost:9292` in your browser.

### Environment Configuration

Copy `.env.sample` to `.env` and adjust settings as needed:

```bash
cp .env.sample .env
```

## Development

### Running Tests

The project now includes a test suite using `rack-test` and `test-unit`. To run tests:

```bash
# Run all tests
rake test

# Create test directory structure (first time setup)
rake test:create
```

Tests are located in the `test/` directory and follow the naming pattern `*_test.rb`.

### Code Quality

The project uses Standard Ruby for code formatting:

```bash
# Check code style
rake standard

# Auto-fix code style issues
rake standard:fix
```

### Database Tasks

```bash
# Run migrations
rake db:migrate

# Create a new migration
rake db:create_migration[create_users_table]

# Rollback last migration
rake db:rollback
```

### Asset Compilation

```bash
# Compile assets
rake assets:compile

# Watch for asset changes (development)
rake assets:watch
```

## Architecture

Relay is built as a Rack application using Roda for routing. The application follows a modular structure:

- `app/routes/` - Route definitions
- `app/models/` - Database models
- `app/views/` - View templates
- `app/tools/` - Tool implementations
- `app/assets/` - Static assets
- `app/workers/` - Background job workers

### Key Components

1. **Router** (`app/init/router.rb`) - Main Roda application
2. **Database** (`app/init/database.rb`) - Sequel configuration
3. **Tools** (`app/init/tools.rb`) - Tool registration and management
4. **WebSocket** (`app/routes/websocket.rb`) - WebSocket handler

## API Endpoints

- `GET /` - Redirects to sign-in
- `GET /sign-in` - Sign-in page
- `POST /sign-in` - Authenticate user
- `GET /api/models` - List available models (requires auth)
- `GET /api/providers` - List available providers (requires auth)
- `GET /api/tools` - List available tools (requires auth)
- `GET /health` - Health check endpoint
- `GET /ws` - WebSocket connection

## WebSocket Protocol

The WebSocket endpoint supports real-time communication with LLM models. Connect to `ws://localhost:9292/ws` and send JSON messages following the protocol defined in `app/routes/websocket.rb`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.