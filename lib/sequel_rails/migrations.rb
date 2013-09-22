require 'sequel/extensions/migration'

module SequelRails
  class Migrations
    class << self
      def migrate(version=nil)
        opts = {}
        opts[:target] = version.to_i if version
        ::Sequel::Migrator.run(::Sequel::Model.db, Rails.root.join("db/migrate"), opts)
      end
      alias_method :migrate_up!, :migrate
      alias_method :migrate_down!, :migrate

      def pending_migrations?
        return false unless File.exists?(Rails.root.join("db/migrate"))
        !::Sequel::Migrator.is_current?(::Sequel::Model.db, Rails.root.join("db/migrate"))
      end

      def dump_schema_information(opts={})
        sql = opts.fetch :sql
        db = ::Sequel::Model.db
        migrations_dir = Rails.root.join("db/migrate")
        migrator_class = ::Sequel::Migrator.send(:migrator_class, migrations_dir)
        migrator = migrator_class.new db, migrations_dir

        inserts = migrator.ds.map do |hash|
          insert = migrator.ds.insert_sql(hash)
          sql ? "#{insert};" : "    self << #{insert.inspect}"
        end
        res = ""
        if inserts.any?
          res << "Sequel.migration do\n  change do\n" unless sql
          res << inserts.join("\n")
          res << "\n  end\nend\n" unless sql
        end
        res
      end
    end
  end
end
