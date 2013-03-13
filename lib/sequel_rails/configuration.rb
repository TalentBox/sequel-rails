require 'active_support/core_ext/class/attribute_accessors'

module SequelRails

  mattr_accessor :configuration

  def self.setup(environment)
    config = configuration.environment_for(environment.to_s)
    if config['url']
      ::Sequel.connect config['url'], config
    else
      ::Sequel.connect config
    end
  end

  class Configuration < ActiveSupport::OrderedOptions

    def self.for(root, database_yml_hash)
      ::SequelRails.configuration ||= new(root, database_yml_hash)
    end

    attr_reader :root, :raw
    attr_accessor :logger
    attr_accessor :migration_dir

    def environment_for(name)
      environments[name.to_s] || environments[name.to_sym]
    end

    def environments
      @environments ||= raw.inject({}) do |normalized, environment|
        name, config = environment.first, environment.last
        normalized[name] = normalize_repository_config(config)
        normalized
      end
    end

  private

    def initialize(root, database_yml_hash)
      @root, @raw = root, database_yml_hash
    end

    def normalize_repository_config(hash)
      config = {}
      hash.each do |key, value|
        config[key.to_s] =
          if key.to_s == 'port'
            value.to_i
          elsif key.to_s == 'adapter' && value == 'sqlite3'
            'sqlite'
          elsif key.to_s == 'database' && (hash['adapter'] == 'sqlite3' ||
                                           hash['adapter'] == 'sqlite'  ||
                                           hash[:adapter]  == 'sqlite3' ||
                                           hash[:adapter]  == 'sqlite')
            value == ':memory:' ? value : File.expand_path((hash['database'] || hash[:database]), root)
          elsif key.to_s == 'adapter' && value == 'postgresql'
            'postgres'
          else
            value
          end
      end

      # always use jdbc when running jruby
      if SequelRails.jruby?
        if config['adapter']
          case config['adapter'].to_sym
            when :postgres
              config['adapter'] = :postgresql
          end
          config['adapter'] = "jdbc:#{config['adapter']}"
        end
      end

      # some adapters only support an url
      if config['adapter'] && config['adapter'] =~ /^(jdbc|do):/
        params = {}
        config.each do |k, v|
          next if ['adapter', 'host', 'port', 'database'].include?(k)
          params[k] = v
        end
        params_str = params.map { |k, v| "#{k}=#{v}" }.join('&')
        port = config['port'] ? ":#{config['port']}" : ''
        config['url'] = case config['adapter']
        when /sqlite/
          "%s:%s" % [config['adapter'], config['database']]
        else
          "%s://%s%s/%s?%s" % [config['adapter'], config['host'], port, config['database'], params_str]
        end
      end

      config
    end

  end

end
