require 'sequel_rails/storage'

# TODO: DRY these up
namespace :db do
  def db_for_current_env
    @db_for_current_env ||= {}
    @db_for_current_env[Rails.env] ||= ::SequelRails.setup(Rails.env)
  end

  # desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => [:environment, "db:migrate:load"] do
    if SequelRails::Migrations.pending_migrations?
      puts "You have pending migrations:"
      abort %{Run `rake db:migrate` to update your database then try again.}
    end
  end

  namespace :schema do
    desc "Create a db/schema.rb file that can be portably used against any DB supported by Sequel"
    task :dump => :environment do
      db_for_current_env.extension :schema_dumper
      File.open(ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb", "w") do |file|
        file.write db_for_current_env.dump_schema_migration(:same_db => true)
      end
      Rake::Task["db:schema:dump"].reenable
    end

    desc "Load a schema.rb file into the database"
    task :load => :environment do
      file = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      if File.exists?(file)
        require 'sequel/extensions/migration'
        load(file)
        ::Sequel::Migration.descendants.first.apply(db_for_current_env, :up)
      else
        abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again. If you do not intend to use a database, you should instead alter #{Rails.root}/config/boot.rb to limit the frameworks that will be loaded}
      end
    end
  end

  namespace :structure do
    desc "Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql"
    task :dump, [:env] => :environment do |t, args|
      args.with_defaults(:env => Rails.env)
      
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      unless SequelRails::Storage.dump_environment args.env, filename
        abort "Could not dump structure for #{args.env}."
      end
      
      Rake::Task["db:structure:dump"].reenable
    end

    task :load, [:env] => :environment do |t, args|
      args.with_defaults(:env => Rails.env)
      
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      unless SequelRails::Storage.load_environment args.env, filename
        abort "Could not load structure for #{args.env}."
      end
    end
  end
  
  task dump: :environment do
    case (SequelRails.configuration.schema_format ||= :ruby)
    when :ruby
      Rake::Task["db:schema:dump"].invoke
    when :sql
      Rake::Task["db:structure:dump"].invoke
    else
      abort "unknown schema format #{SequelRails.configuration.schema_format}"
    end
  end
  
  task load: :environment do
    case (SequelRails.configuration.schema_format ||= :ruby)
    when :ruby
      Rake::Task["db:schema:load"].invoke
    when :sql
      Rake::Task["db:structure:load"].invoke
    else
      abort "unknown schema format #{SequelRails.configuration.schema_format}"
    end
  end
  
  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :environment do
      unless SequelRails::Storage.create_all
        abort "Could not create all databases."
      end
    end
  end

  desc "Create the database defined in config/database.yml for the current Rails.env"
  task :create, [:env] => :environment do |t, args|
    args.with_defaults(:env => Rails.env)

    unless SequelRails::Storage.create_environment(args.env)
      abort "Could not create database for #{args.env}."
    end
  end

  namespace :drop do
    desc 'Drops all the local databases defined in config/database.yml'
    task :all => :environment do
      unless SequelRails::Storage.drop_all
        warn "Couldn't drop all databases"
      end
    end
  end

  desc "Drop the database defined in config/database.yml for the current Rails.env"
  task :drop, [:env] => :environment do |t, args|
    args.with_defaults(:env => Rails.env)

    unless SequelRails::Storage.drop_environment(args.env)
      warn "Couldn't drop database for environment #{args.env}"
    end
  end

  namespace :migrate do
    task :load => :environment do
      require 'sequel_rails/migrations'
    end

    desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :load do
      if ENV["VERSION"]
        Rake::Task["db:migrate:down"].invoke
        Rake::Task["db:migrate:up"].invoke
      else
        Rake::Task["db:rollback"].invoke
        Rake::Task["db:migrate"].invoke
      end
    end

    desc 'Resets your database using your migrations for the current environment'
    task :reset => ["db:drop", "db:create", "db:migrate"]

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :load do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      SequelRails::Migrations.migrate_up!(version)
      Rake::Task["db:dump"].invoke unless Rails.env.test?
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :load do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      SequelRails::Migrations.migrate_down!(version)
      Rake::Task["db:dump"].invoke unless Rails.env.test?
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => "migrate:load" do
    SequelRails::Migrations.migrate_up!(ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:dump"].invoke unless Rails.env.test?
  end

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :abort_if_pending_migrations do
    seed_file = File.join(Rails.root, 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end

  desc 'Create the database, load the schema, and initialize with the seed data'
  task :setup => [ 'db:create', 'db:load', 'db:seed' ]

  desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
  task :reset => [ 'db:drop', 'db:setup' ]

  desc 'Forcibly close any open connections to the current env database (PostgreSQL specific)'
  task :force_close_open_connections, [:env] => :environment do |t, args|
    args.with_defaults(:env => Rails.env)
    SequelRails::Storage.close_connections_environment(args.env)
  end

  namespace :test do
    desc "Prepare test database (ensure all migrations ran, drop and re-create database then load schema). This task can be run in the same invocation as other task (eg: rake db:migrate db:test:prepare)."
    task :prepare => "db:abort_if_pending_migrations" do
      previous_env, Rails.env = Rails.env, 'test'
      Rake::Task['db:drop'].execute
      Rake::Task['db:create'].execute
      Rake::Task['db:load'].execute
      Sequel::DATABASES.each do |db|
        db.disconnect
      end
      Rails.env = previous_env
    end
  end
end

task "test:prepare" => "db:test:prepare"
