# frozen_string_literal: true

namespace :dev do
  desc "Start the dev environment"
  task :start do
    monitor = Relay::TaskMonitor.new(
      tasks: %w[assets:build assets:watch dev:server dev:sidekiq]
    )
    monitor.prefork { Relay::DB.disconnect }
    monitor.monitor
  end

  desc "Serve the server"
  task :server do
    sh "env RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT=67108864 $(cat .env) " \
       "bundle exec falcon serve --bind http://0.0.0.0:9292"
  end

  desc "Run Sidekiq"
  task :sidekiq do
    sh "env $(cat .env) " \
       "bundle exec sidekiq -C app/config/sidekiq.yml -r ./app/init.rb"
  end
end
