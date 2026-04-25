# frozen_string_literal: true

ENV["RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT"] ||= (64 * 1024 * 1024).to_s

require_relative "app/init"

use Rack::Static, urls: ["/g", "/images", "/stylesheets", "/js"], root: "public"

case Relay.environment
when "development"
  use Rack::Reloader
  use Rack::Lint
  use Rack::TempfileReaper
  use Rack::ContentLength
  use Rack::ETag
  use Rack::ConditionalGet
  use Rack::Head
  use Relay::Reloader
  map("/sidekiq") { run Sidekiq::Web }
end

run Relay::Router
