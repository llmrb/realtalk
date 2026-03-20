# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

require "active_record"
require "erb"
require "yaml"

require_relative "../../db/config"
DB.establish_connection!(env: ENV["RACK_ENV"] || "development")

require_relative "sidekiq"
require_relative "tools/init"
require_relative "models/init"
require_relative "workers/init"
require_relative "routes/init"
require_relative "router"
