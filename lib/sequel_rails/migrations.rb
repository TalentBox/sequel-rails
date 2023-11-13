require 'sequel/extensions/migration'

module SequelRails
  class Migrations
    class << self
      def migrate(version = nil, migrator_class = ::Sequel::Migrator, opts = {})
        opts[:target] = version.to_i if version
        opts[:allow_missing_migration_files] = !!SequelRails.configuration.allow_missing_migration_files

        if migrations_dir.directory?
          migrator_class.run(::Sequel::Model.db, migrations_dir, opts)
        else
          relative_path_name = migrations_dir.relative_path_from(Rails.root).to_s
          raise "The #{relative_path_name} directory doesn't exist, you need to create it."
        end
      end
      alias_method :migrate_up!, :migrate
      alias_method :migrate_down!, :migrate

      def migrate_up_one_version!(version)
        migrate(version, SequelRails::OneTimestampVersionMigrator, { direction: :up })
      end

      def migrate_down_one_version!(version)
        migrate(version, SequelRails::OneTimestampVersionMigrator, { direction: :down })
      end

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

  class OneTimestampVersionMigrator < ::Sequel::TimestampMigrator
    Error = ::Sequel::Migrator::Error

    # The direction of the migrator, either :up or :down
    attr_reader :direction

    # Set up all state for the migrator instance
    def initialize(db, directory, opts = OPTS)
      @direction = opts[:direction]
      super

      raise(Error, 'target (version) is absent') if target.nil?
      raise(Error, "Invalid direction: #{direction}") unless [:up, :down].include?(direction)
      # `allow_missing_migration_files` ignored, as version is from user input
      raise(Error, "Migration with version #{target} not found") if migration_tuples.empty?
    end

    private

    # This is overriding parent method, no way to choose another method name
    # rubocop:disable Naming/AccessorMethodName
    def get_migration_tuples
      up_mts = []
      down_mts = []
      files.each do |path|
        f = File.basename(path)
        fi = f.downcase
        next unless migration_version_from_file(f) == target

        case [direction, applied_migrations.include?(fi)]
        when [:up, false]
          # Normal migrate up
          up_mts << [load_migration_file(path), f, :up]
        when [:down, true]
          # Normal migrate down
          down_mts << [load_migration_file(path), f, :down]
        else
          # Already run, don't re-run
          raise(Error, "Migration with version #{target} is already migrated/rollback")
        end
      end
      up_mts + down_mts.reverse
    end
    # rubocop:enable Naming/AccessorMethodName
  end
end
