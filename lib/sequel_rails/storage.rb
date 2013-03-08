require "sequel_rails/storage/abstract"
require "sequel_rails/storage/sqlite"
require "sequel_rails/storage/mysql"
require "sequel_rails/storage/mysql2"
require "sequel_rails/storage/postgres"
require "sequel_rails/storage/jdbc"

module SequelRails
  module Storage
    def self.create_all
      with_local_repositories { |config| create_environment(config) }
    end

    def self.drop_all
      with_local_repositories { |config| drop_environment(config) }
    end

    def self.create_environment(config_or_env)
      adapter_for(config_or_env).create
    end

    def self.drop_environment(config_or_env)
      adapter = adapter_for(config_or_env)
      adapter.close_connections
      adapter.drop
    end

    def self.close_all_connections
      with_all_repositories { |config| close_connections_environment(config) }
    end

    def self.close_connections_environment(config_or_env)
      adapter_for(config_or_env).close_connections
    end

    def self.adapter_for(config_or_env)
      config = if config_or_env.kind_of? Hash
                 config_or_env
               else
                 ::SequelRails.configuration.environments[config_or_env.to_s]
               end
      lookup_class(config['adapter']).new config
    end

    private

    def self.with_local_repositories
      ::SequelRails.configuration.environments.each_value do |config|
        next if config['database'].blank? || config['adapter'].blank?
        if config['host'].blank? || %w[ 127.0.0.1 localhost ].include?(config['host'])
          yield config
        else
          puts "This task only modifies local databases. #{config['database']} is on a remote host."
        end
      end
    end

    def self.with_all_repositories
      ::SequelRails.configuration.environments.each_value do |config|
        next if config['database'].blank? || config['adapter'].blank?
        yield config
      end
    end

    def self.lookup_class(adapter)
      raise "Adapter not specified in config, please set the :adapter key." unless adapter
      return Jdbc if adapter =~ /jdbc/

      klass_name = adapter.camelize.to_sym
      unless self.const_defined?(klass_name)
        raise "Adapter #{adapter} not supported (#{klass_name.inspect})"
      end

      const_get klass_name
    end
  end
end
