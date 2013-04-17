require 'shellwords'

module SequelRails
  module Storage
    class Mysql < Abstract
      def _create
        execute("CREATE DATABASE IF NOT EXISTS `#{database}` DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}")
      end

      def _drop
        execute("DROP DATABASE IF EXISTS `#{database}`")
      end

      def _dump filename
        commands = %w(mysqldump --no-data)
        commands << "--user=#{Shellwords.escape(username)}" unless username.blank?
        commands << "--password=#{Shellwords.escape(password)}" unless password.blank?
        commands << "--host=#{host}" unless host.blank?
        commands << "--result-file" << filename
        commands << database
        system(*commands)
      end

      def _load filename
        commands = %w(mysql)
        commands << "--user=#{Shellwords.escape(username)}" unless username.blank?
        commands << "--password=#{Shellwords.escape(password)}" unless password.blank?
        commands << "--host=#{host}" unless host.blank?
        commands << '--execute' << %{SET FOREIGN_KEY_CHECKS = 0; SOURCE #{filename}; SET FOREIGN_KEY_CHECKS = 1}
        commands << '--database' << database
        system(*commands)
      end

      private

      def execute(statement)
        commands = ["mysql"]
        commands << "--user=#{Shellwords.escape(username)}" unless username.blank?
        commands << "--password=#{Shellwords.escape(password)}" unless password.blank?
        commands << "--host=#{host}" unless host.blank?
        commands << "-e" << statement
        system(*commands)
      end

      def collation
        @collation ||= config['collation'] || ENV['COLLATION'] || 'utf8_unicode_ci'
      end

    end
  end
end
