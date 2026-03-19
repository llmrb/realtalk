# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

require "active_record"
require "erb"
require "yaml"

require_relative "db/config"
DB.establish_connection!(env: ENV["RACK_ENV"] || "development")

Dir[File.join(__dir__, "app", "server", "*.rb")].sort.each { require(_1) }
Dir[File.join(__dir__, "app", "server", "models", "*.rb")].sort.each { require(_1) }
Dir[File.join(__dir__, "app", "server", "tools", "*.rb")].sort.each { require(_1) }

use Rack::Static, urls: ["/g"], root: "public"
run Server::Router
