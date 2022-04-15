require 'sequel/extensions/migration'

module SequelRails
  class Migrations
    class << self
      def migrate(version = nil)
        opts = {}
        opts[:target] = version.to_i if version
        opts[:allow_missing_migration_files] = !!SequelRails.configuration.allow_missing_migration_files

        if migrations_dir.directory?
          ::Sequel::Migrator.run(::Sequel::Model.db, migrations_dir, opts)
        else
          relative_path_name = migrations_dir.relative_path_from(Rails.root).to_s
          raise "The #{relative_path_name} directory doesn't exist, you need to create it."
        end
      end
      alias_method :migrate_up!, :migrate
      alias_method :migrate_down!, :migrate

      def pending_migrations?
        return false unless available_migrations?
        !::Sequel::Migrator.is_current?(::Sequel::Model.db, migrations_dir)
      end

      def dump_schema_information(opts = {})
        sql = opts.fetch :sql
        adapter = SequelRails::Storage.adapter_for(Rails.env)
        res = ''

        if available_migrations?
          migrator = init_migrator
          res << adapter.schema_information_dump(migrator, sql)
        end
        res
      end

      def migrations_dir
        Rails.root.join('db/migrate')
      end

      def current_migration
        return unless available_migrations?

        migrator = init_migrator

        if migrator.respond_to?(:applied_migrations)
          migrator.applied_migrations.last
        elsif migrator.respond_to?(:current_version)
          migrator.current_version
        end
      end

      def previous_migration
        return unless available_migrations?

        migrator = init_migrator

        if migrator.respond_to?(:applied_migrations)
          migrator.applied_migrations[-2] || '0'
        elsif migrator.respond_to?(:current_version)
          migrator.current_version - 1
        end
      end

      def available_migrations?
        File.exist?(migrations_dir) && Dir[File.join(migrations_dir, '*')].any?
      end

      def init_migrator
        migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)

        migrator_class.new(
          ::Sequel::Model.db,
          migrations_dir,
          allow_missing_migration_files: !!SequelRails.configuration.allow_missing_migration_files
        )
      end
    end
  end
end
