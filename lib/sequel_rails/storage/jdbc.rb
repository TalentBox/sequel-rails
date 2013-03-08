module SequelRails
  module Storage
    class Jdbc < Abstract

      def _is_mysql?
        config['adapter'].match(/^jdbc:mysql/)
      end

      def _is_postgres?
        config['adapter'].match(/^jdbc:postgresql/)
      end

      def _root_url
        config['url'].scan(/^jdbc:mysql:\/\/\w*:?\d*/)
      end

      def db_name
        config['database']
      end

      def _params
        config['url'].scan(/\?.*$/)
      end

      def _create
        if _is_mysql?
          ::Sequel.connect("#{_root_url}#{_params}") do |db|
            db.execute("CREATE DATABASE IF NOT EXISTS `#{db_name}` DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}")
          end
        elsif _is_postgres?
          system("createdb #{db_name}")
        end
      end

      def _drop
        if _is_mysql?
          ::Sequel.connect("#{_root_url}#{_params}") do |db|
            db.execute("DROP DATABASE IF EXISTS `#{db_name}`")
          end
        elsif _is_postgres?
          system("dropdb #{db_name}")
        end
      end

      private

      def collation
        @collation ||= config['collation'] || ENV['COLLATION'] || 'utf8_unicode_ci'
      end

    end
  end
end
