require 'sequel/extensions/migration'

module SequelRails
  class Migrations
    class << self
      def migrate(version = nil)
        opts = {}
        opts[:target] = version.to_i if version
        temporarily_merge_migration_files("run the migration") do
          ::Sequel::Migrator.run(::Sequel::Model.db, migrations_dir, opts)
        end
      end
      alias_method :migrate_up!, :migrate
      alias_method :migrate_down!, :migrate

      def pending_migrations?
        return false unless available_migrations?
        temporarily_merge_migration_files do
          !::Sequel::Migrator.is_current?(::Sequel::Model.db, migrations_dir)
        end
      end

      def dump_schema_information(opts = {})
        sql = opts.fetch :sql
        adapter = SequelRails::Storage.adapter_for(Rails.env)
        db = ::Sequel::Model.db
        res = ''

        if available_migrations?
          temporarily_merge_migration_files do
            migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)
            migrator = migrator_class.new db, migrations_dir
            res << adapter.schema_information_dump(migrator, sql)
          end
        end
        res
      end

      def migrations_dir
        Rails.root.join('db/migrate')
      end

      def current_migration
        return unless available_migrations?
        temporarily_merge_migration_files("determine the current_migration") do
          migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)
          migrator = migrator_class.new ::Sequel::Model.db, migrations_dir
          if migrator.respond_to?(:applied_migrations)
            migrator.applied_migrations.last
          elsif migrator.respond_to?(:current_version)
            migrator.current_version
          end
        end
      end

      def previous_migration
        return unless available_migrations?
        temporarily_merge_migration_files("determine the previous_migration") do
          migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)
          migrator = migrator_class.new ::Sequel::Model.db, migrations_dir
          if migrator.respond_to?(:applied_migrations)
            migrator.applied_migrations[-2] || '0'
          elsif migrator.respond_to?(:current_version)
            migrator.current_version - 1
          end
        end
      end

      def available_migrations?
        temporarily_merge_migration_files do
          File.exist?(migrations_dir) && Dir[File.join(migrations_dir, '*')].any?
        end
      end

      # Temporarily merges the migration files by copying them over and then deletes them.
      # Sequel's migration class cannot work with migrations in different directories even if sequel-rails can.
      # This is the simplest solution that works until ::Sequel::Migrator supports merging of multiple migration
      # directories.
      def temporarily_merge_migration_files(explanation=nil)
        copy_files = []
        Rails.application.config.paths["db/migrate"].expanded.each do |specified_migration_dir|
          if migrations_dir.to_s != specified_migration_dir
            Dir[File.join(specified_migration_dir, '*')].each do |file_name|
              copy_files.push([file_name, migrations_dir.join(File.basename(file_name)).to_s])
            end
          end
        end
        if explanation && copy_files.any?
          puts "Detected migration files outside of the main db/migrate directory. Copying them to db/migrate temporarily to #{explanation}:"
          copy_files.each { |o, _| puts " - #{o}"}
        end
        copy_files.each { |original, destination| FileUtils.cp(original, destination) }
        yield
      ensure
        copy_files.each { |_, destination| FileUtils.rm_f(destination) }
      end

    end
  end
end
