require 'uri'
require 'cgi'

module SequelRails
  module Storage
    class Jdbc < Abstract
      def _is_mysql?
        config['adapter'].start_with?('jdbc:mysql')
      end

      def _is_postgres?
        config['adapter'].start_with?('jdbc:postgresql')
      end

      def _is_sqlite?
        config['adapter'].start_with?('jdbc:sqlite')
      end

      def _root_url
        config['url'].scan(%r{^jdbc:mysql://[\w\.]*:?\d*}).first
      end

      def db_name
        config['database']
      end

      def _params
        config['url'].scan(/\?.*$/).first
      end

      def _create
        if _is_sqlite?
          return if in_memory?
          ::Sequel.connect config['url']
        elsif _is_mysql?
          ::Sequel.connect("#{_root_url}#{_params}") do |db|
            db.execute("CREATE DATABASE IF NOT EXISTS `#{db_name}` DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}")
          end
        elsif _is_postgres?
          extract_postgresql_jdbc_config
          adapter = ::SequelRails::Storage::Postgres.new(config)
          adapter._create
        end
      end

      def _drop
        if _is_sqlite?
          return if in_memory?
          FileUtils.rm db_name if File.exist? db_name
        elsif _is_mysql?
          ::Sequel.connect("#{_root_url}#{_params}") do |db|
            db.execute("DROP DATABASE IF EXISTS `#{db_name}`")
          end
        elsif _is_postgres?
          extract_postgresql_jdbc_config
          adapter = ::SequelRails::Storage::Postgres.new(config)
          adapter._drop
        end
      end

      def _dump(filename)
        if _is_postgres?
          extract_postgresql_jdbc_config
          adapter = ::SequelRails::Storage::Postgres.new(config)
          adapter._dump(filename)
        else
          raise NotImplementedError
        end
      end

      def _load(filename)
        if _is_postgres?
          extract_postgresql_jdbc_config
          adapter = ::SequelRails::Storage::Postgres.new(config)
          adapter._load(filename)
        else
          raise NotImplementedError
        end
      end

      def schema_information_dump(migrator, sql_dump)
        if _is_postgres?
          schema_information_dump_with_search_path(migrator, sql_dump)
        else
          super
        end
      end

      private

      def extract_postgresql_jdbc_config
        if config["url"]
          uri = URI.parse(config["url"].split(":", 2).last)
          params = CGI::parse(uri.query || "")

          config["database"] ||= uri.path.tr("/", "")
          config["username"] ||= config["user"] || (params["user"] && params["user"].first)
          config["password"] ||= params["password"] && params["password"].first
          config["host"] ||= uri.host
          config["port"] ||= uri.port
        end
      end

      def collation
        @collation ||= super || 'utf8_unicode_ci'
      end

      def in_memory?
        return false unless _is_sqlite?
        database == ':memory:'
      end
    end
  end
end
