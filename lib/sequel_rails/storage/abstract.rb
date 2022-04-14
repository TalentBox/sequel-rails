module SequelRails
  module Storage
    class Abstract
      attr_reader :config

      def initialize(config)
        @config = config
        parse_url
      end

      def create
        res = _create
        warn "[sequel] Created database '#{database}'" if res
        res
      end

      def drop
        return if ::Sequel::DATABASES.size == 0

        ::Sequel::Model.db.disconnect
        res = _drop
        warn "[sequel] Dropped database '#{database}'" if res
        res
      end

      def dump(filename)
        res = _dump filename
        warn "[sequel] Dumped structure of database '#{database}' to '#{filename}'" if res
        res
      end

      def load(filename)
        res = _load filename
        warn "[sequel] Loaded structure of database '#{database}' from '#{filename}'" if res
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

      def collation
        @collation ||= config['collation'] || ENV['COLLATION']
      end

      def search_path
        @search_path ||= config['search_path'] || '"$user", public'
      end

      def schema_information_dump(migrator, sql_dump)
        res = ''
        inserts = schema_information_inserts(migrator, sql_dump)
        if inserts.any?
          res = inserts.join("\n")
          unless sql_dump
            res = <<-RUBY.strip_heredoc
              Sequel.migration do
                change do
                  #{res}
                end
              end
            RUBY
          end
        end
        res
      end

      private

      def parse_url
        return unless @config['url'].present?

        url = URI(@config['url'])

        username, password = url.userinfo.to_s.split(':')
        @config.reverse_merge!(
          'database' => url.path.to_s[1..-1],
          'username' => username,
          'password' => password,
          'host' => url.host,
          'port' => url.port
        )
      end

      def add_option(commands, name, value)
        return unless value.present?
        separator = name[0, 2] == '--' ? '=' : ' '
        commands << "#{name}#{separator}#{value}"
      end

      def add_flag(commands, flag)
        commands << flag
      end

      def exec(escaped_command)
        `#{escaped_command}`

        # Evaluate command status as a boolean like `system` does.
        $CHILD_STATUS.exitstatus == 0
      end

      def safe_exec(args)
        if !Gem.win_platform?
          exec SequelRails::Shellwords.join(Array(args))
        else
          jarg = args.map do |arg|
            str = arg.to_s
            return "''" if str.empty?
            str = str.dup
            str.gsub!(%r{([^A-Za-z0-9_\-.,:/@\n])}, '\\1')
            str.gsub!(/\n/, "'\n'")
            str
          end
          exec jarg.join(' ')
        end
      end

      def schema_information_inserts(migrator, sql_dump)
        migrator.ds.map do |hash|
          insert = migrator.ds.insert_sql(hash)
          sql_dump ? "#{insert};" : "self << #{insert.inspect}"
        end
      end

      def schema_information_dump_with_search_path(migrator, sql_dump)
        res = ''
        inserts = schema_information_inserts(migrator, sql_dump)
        if inserts.any?
          set_search_path_sql = "SET search_path TO #{search_path}"
          res = inserts.join("\n")
          if sql_dump
            res = "#{set_search_path_sql};\n#{res}"
          else
            res = <<-RUBY.strip_heredoc
              Sequel.migration do
                change do
                  self << #{set_search_path_sql.inspect}
                  #{res}
                end
              end
            RUBY
          end
        end
        res
      end
    end
  end
end
