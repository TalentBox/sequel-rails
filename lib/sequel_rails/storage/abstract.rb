module SequelRails
  module Storage
    class Abstract

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def create
        res = _create
        puts "[sequel] Created database '#{database}'" if res
        res
      end

      def drop
        ::Sequel::Model.db.disconnect
        res = _drop
        puts "[sequel] Dropped database '#{database}'" if res
        res
      end

      def dump filename
        res = _dump filename
        puts "[sequel] Dumped structure of database '#{database}' to '#{filename}'" if res
        res
      end

      def load filename
        res = _load filename
        puts "[sequel] Loaded structure of database '#{database}' from '#{filename}'" if res
        res
      end

      # To be overriden by subclasses
      def close_connections
        true
      end

      def database
        @database ||= config['database'] || config['path']
      end

      def username
        @username ||= config['username'] || config['user'] || ''
      end

      def password
        @password ||= config['password'] || ''
      end

      def host
        @host ||= config['host'] || ''
      end

      def port
        @port ||= config['port'] || ''
      end

      def owner
        @owner ||= config['owner'] || ''
      end

      def charset
        @charset ||= config['charset'] || ENV['CHARSET'] || 'utf8'
      end

    end
  end
end
