module SequelRails
  module Storage
    class Postgres < Abstract
      def _create
        ENV["PGPASSWORD"] = password unless password.blank?
        commands = ["createdb", "--encoding", charset]
        commands << "--username" << username unless username.blank?
        commands << "--owner" << owner unless owner.blank?
        commands << "--port" << port.to_s unless port.blank?
        commands << "--host" << host unless host.blank?
        commands << database
        res = system(*commands)
        ENV["PGPASSWORD"] = nil unless password.blank?
        res
      end

      def _drop
        ENV["PGPASSWORD"] = password unless password.blank?
        commands = ["dropdb"]
        commands << "-U" << username unless username.blank?
        commands << "--port" << port.to_s unless port.blank?
        commands << "--host" << host unless host.blank?
        commands << database
        res = system(*commands)
        ENV["PGPASSWORD"] = nil unless password.blank?
        res
      end
      
      def _dump filename
        ENV["PGPASSWORD"] = password unless password.blank?
        commands = %w(pg_dump -i -s -x -O)
        commands << "-f" << filename
        commands << "-U" << username unless username.blank?
        commands << "--port" << port.to_s unless port.blank?
        commands << "--host" << host unless host.blank?
        commands << database
        res = system(*commands)
        ENV["PGPASSWORD"] = nil unless password.blank?
        res
      end

      def _load filename
        ENV["PGPASSWORD"] = password unless password.blank?
        commands = %w(psql)
        commands << "-f" << filename
        commands << "-U" << username unless username.blank?
        commands << "--port" << port.to_s unless port.blank?
        commands << "--host" << host unless host.blank?
        commands << database
        res = system(*commands)
        ENV["PGPASSWORD"] = nil unless password.blank?
        res
      end

      def close_connections
        begin
          db = ::Sequel.connect(config)
          # Will only work on Postgres > 8.4
          pid_column = db.server_version < 90200 ? "procpid" : "pid"
          db.execute <<-SQL.gsub(/^\s{12}/,'')
            SELECT COUNT(pg_terminate_backend(#{pid_column}))
            FROM pg_stat_activity
            WHERE datname = '#{database}';
          SQL
        rescue => _
          # Will raise an error as it kills existing process running this 
          # command. Seems to be only way to ensure *all* test connections 
          # are closed
        end
      end
    end
  end
end
