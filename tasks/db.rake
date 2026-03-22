Sequel.extension :migration

namespace :db do
  version = proc {
    migrator = Sequel::TimestampMigrator.new(Relay::DB, File.join(__dir__, "..", "db", "migrate"))
    migrator.applied_migrations.max.to_s.split("_", 2).first.to_i
  }.call

  desc "Run database migrations"
  task :migrate do
    Sequel::Migrator.run(Relay::DB, File.join(__dir__, "db", "migrate"))
  end

  desc "Rollback the latest migration"
  task :rollback do
    abort "no migrations applied" if version..zero?
    path = File.join(__dir__, "db", "migrate")
    Sequel::Migrator.run(Relay::DB, path, target: version - 1)
  end

  desc "Print the current migration version"
  task :version do
    puts version
  end

  namespace :migration do
    desc "Create a new migration"
    task :new, [:name] do |_task, args|
      abort "usage: rake db:migrate:new[name]" if args[:name].to_s.empty?
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      path = File.join(__dir__, "db", "migrate", "#{timestamp}_#{args[:name]}.rb")
      erb = ERB.new File.read("templates/migration.rb.erb")
      File.write(path, erb.result(binding))
      puts path
    end
  end
end

