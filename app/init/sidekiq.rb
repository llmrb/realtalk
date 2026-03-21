# frozen_string_literal: true

require "sidekiq"
require "sidekiq/web"

redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }

Sidekiq.configure_client do |config|
  config.redis = redis
end

Sidekiq.configure_server do |config|
  config.redis = redis
end
