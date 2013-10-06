require 'sequel/extensions/migration'

module SequelRails
  class Migrations
    class << self
      def migrate(version=nil)
        opts = {}
        opts[:target] = version.to_i if version
        ::Sequel::Migrator.run(::Sequel::Model.db, migrations_dir, opts)
      end
      alias_method :migrate_up!, :migrate
      alias_method :migrate_down!, :migrate

      def pending_migrations?
        return false unless available_migrations?
        !::Sequel::Migrator.is_current?(::Sequel::Model.db, migrations_dir)
      end

      def dump_schema_information(opts={})
        sql = opts.fetch :sql
        db = ::Sequel::Model.db
        res = ""

        if available_migrations?
          migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)
          migrator = migrator_class.new db, migrations_dir

          inserts = migrator.ds.map do |hash|
            insert = migrator.ds.insert_sql(hash)
            sql ? "#{insert};" : "    self << #{insert.inspect}"
          end

          if inserts.any?
            res << "Sequel.migration do\n  change do\n" unless sql
            res << inserts.join("\n")
            res << "\n  end\nend\n" unless sql
          end
        end
        res
      end

      def migrations_dir
        Rails.root.join("db/migrate")
      end

      def available_migrations?
        File.exists?(migrations_dir) && Dir[File.join(migrations_dir, '*')].any?
      end
    end
  end
end
