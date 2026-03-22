# frozen_string_literal: true

namespace :assets do
  desc "Watch frontend assets"
  task :watch do
    Dir.chdir Relay.assets_dir do
      sh "npm run assets:watch"
    end
  end

  desc "Build frontend assets"
  task :build do
    Dir.chdir Relay.assets_dir do
      sh "npm install"
      sh "npm run assets:build"
    end
  end
end
