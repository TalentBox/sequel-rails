require 'sequel_rails/storage'

sequel_rails_namespace = SequelRails::TASK_NAMESPACE

# TODO: DRY these up
namespace sequel_rails_namespace do
  def db_for_current_env
    @db_for_current_env ||= {}
    @db_for_current_env[Rails.env] ||= ::SequelRails.setup(Rails.env)
  end

  # desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => [:environment, "#{sequel_rails_namespace}:migrate:load"] do
    if SequelRails::Migrations.pending_migrations?
      warn 'You have pending migrations:'
      abort "Run `rake #{sequel_rails_namespace}:migrate` to update your database then try again."
    end
  end

  namespace :schema do
    desc 'Create a db/schema.rb file that can be portably used against any DB supported by Sequel'
    task :dump => :environment do
      db_for_current_env.extension :schema_dumper
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"

      if Rails.root.join("db").exist?
        File.open filename, 'w' do |file|
          file << db_for_current_env.dump_schema_migration(:same_db => true)
          file << SequelRails::Migrations.dump_schema_information(:sql => false)
        end

        Rake::Task["#{sequel_rails_namespace}:schema:dump"].reenable
      else
        abort "The db/ directory doesn't exist, please create it."
      end
    end

    desc 'Load a schema.rb file into the database'
    task :load => :environment do
      file = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      if File.exist?(file)
        require 'sequel/extensions/migration'
        load(file)
        ::Sequel::Migration.descendants.each { |m| m.apply(db_for_current_env, :up) }
      else
        abort "#{file} doesn't exist yet. Run 'rake #{sequel_rails_namespace}:migrate' to create it, then try again."
      end
    end
  end

  namespace :structure do
    desc 'Dump the database structure to db/structure.sql'
    task :dump, [:env] => :environment do |_t, args|
      db_for_current_env
      args.with_defaults(:env => Rails.env)

      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, 'db', 'structure.sql')
      if SequelRails::Storage.dump_environment args.env, filename
        ::File.open filename, 'a' do |file|
          file << SequelRails::Migrations.dump_schema_information(:sql => true)
        end
      else
        abort "Could not dump structure for #{args.env}."
      end

      Rake::Task["#{sequel_rails_namespace}:structure:dump"].reenable
    end

    task :load, [:env] => :environment do |_t, args|
      args.with_defaults(:env => Rails.env)

      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, 'db', 'structure.sql')
      unless SequelRails::Storage.load_environment args.env, filename
        abort "Could not load structure for #{args.env}."
      end
    end
  end

  task :dump => :environment do
    case (SequelRails.configuration.schema_format ||= :ruby)
    when :ruby
      Rake::Task["#{sequel_rails_namespace}:schema:dump"].invoke
    when :sql
      Rake::Task["#{sequel_rails_namespace}:structure:dump"].invoke
    else
      abort "unknown schema format #{SequelRails.configuration.schema_format}"
    end
  end

  task :load => :environment do
    case (SequelRails.configuration.schema_format ||= :ruby)
    when :ruby
      Rake::Task["#{sequel_rails_namespace}:schema:load"].invoke
    when :sql
      Rake::Task["#{sequel_rails_namespace}:structure:load"].invoke
    else
      abort "unknown schema format #{SequelRails.configuration.schema_format}"
    end
  end

  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :environment do
      abort 'Could not create all databases.' unless SequelRails::Storage.create_all
    end
  end

  desc 'Create the database defined in config/database.yml for the current Rails.env'
  task :create, [:env] => :environment do |_t, args|
    args.with_defaults(:env => Rails.env)

    unless SequelRails::Storage.create_environment(args.env)
      abort "Could not create database for #{args.env}."
    end
  end

  namespace :drop do
    desc 'Drops all the local databases defined in config/database.yml'
    task :all => :environment do
      warn "Couldn't drop all databases" unless SequelRails::Storage.drop_all
    end
  end

  desc 'Drop the database defined in config/database.yml for the current Rails.env'
  task :drop, [:env] => :environment do |_t, args|
    args.with_defaults(:env => Rails.env)

    unless SequelRails::Storage.drop_environment(args.env)
      warn "Couldn't drop database for environment #{args.env}"
    end
  end

  namespace :migrate do
    task :load => :environment do
      require 'sequel_rails/migrations'
      db_for_current_env
    end

    desc 'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :load do
      if ENV['VERSION']
        Rake::Task["#{sequel_rails_namespace}:migrate:down"].invoke
        Rake::Task["#{sequel_rails_namespace}:migrate:up"].invoke
      else
        Rake::Task["#{sequel_rails_namespace}:rollback"].invoke
        Rake::Task["#{sequel_rails_namespace}:migrate"].invoke
      end
    end

    desc 'Resets your database using your migrations for the current environment'
    task :reset => %W(#{sequel_rails_namespace}:drop #{sequel_rails_namespace}:create #{sequel_rails_namespace}:migrate)

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :load do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      SequelRails::Migrations.migrate_up!(version)
      Rake::Task["#{sequel_rails_namespace}:dump"].invoke if SequelRails.configuration.schema_dump
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :load do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      SequelRails::Migrations.migrate_down!(version)
      Rake::Task["#{sequel_rails_namespace}:dump"].invoke if SequelRails.configuration.schema_dump
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => 'migrate:load' do
    SequelRails::Migrations.migrate_up!(ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
    Rake::Task["#{sequel_rails_namespace}:dump"].invoke if SequelRails.configuration.schema_dump
  end

  desc 'Rollback the latest migration file or down to specified VERSION=x'
  task :rollback => 'migrate:load' do
    version = if ENV['VERSION']
                ENV['VERSION'].to_i
              else
                SequelRails::Migrations.previous_migration
              end
    SequelRails::Migrations.migrate_down! version
    Rake::Task["#{sequel_rails_namespace}:dump"].invoke if SequelRails.configuration.schema_dump
  end

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :abort_if_pending_migrations do
    seed_file = File.join(Rails.root, 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end

  desc 'Create the database, load the schema, and initialize with the seed data'
  task :setup => %W(#{sequel_rails_namespace}:create #{sequel_rails_namespace}:load #{sequel_rails_namespace}:seed)

  desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
  task :reset => %W(#{sequel_rails_namespace}:drop #{sequel_rails_namespace}:setup)

  desc 'Forcibly close any open connections to the current env database (PostgreSQL specific)'
  task :force_close_open_connections, [:env] => :environment do |_t, args|
    args.with_defaults(:env => Rails.env)
    SequelRails::Storage.close_connections_environment(args.env)
  end

  namespace :test do
    desc "Prepare test database (ensure all migrations ran, drop and re-create database then load schema). This task can be run in the same invocation as other task (eg: rake #{sequel_rails_namespace}:migrate #{sequel_rails_namespace}:test:prepare)."
    task :prepare => "#{sequel_rails_namespace}:abort_if_pending_migrations" do
      previous_env, Rails.env = Rails.env, 'test'
      Sequel::DATABASES.each(&:disconnect)
      Rake::Task["#{sequel_rails_namespace}:drop"].execute
      Rake::Task["#{sequel_rails_namespace}:create"].execute
      Rake::Task["#{sequel_rails_namespace}:load"].execute
      Sequel::DATABASES.each(&:disconnect)
      Rails.env = previous_env
    end
  end

  namespace :sessions do
    desc 'Clear the sessions table'
    task clear: :environment do
      db_for_current_env.from(:sessions).truncate
    end

    desc 'Trim old sessions from the table (default: > 30 days)'
    task :trim, [:threshold] => :environment do |_, args|
      cutoff_period = (args.fetch(:threshold) { 30 }).to_i.days.ago

      db_for_current_env
        .from(:sessions)
        .where { updated_at < cutoff_period }
        .delete
    end
  end
end

task 'test:prepare' => "#{sequel_rails_namespace}:test:prepare"
