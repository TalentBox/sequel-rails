require 'active_support/core_ext/class/attribute_accessors'

module SequelRails

  mattr_accessor :configuration

  def self.setup(environment, app)
    config = configuration.environment_for(environment.to_s)
    db = if config['url']
      ::Sequel.connect config['url'], config
    else
      ::Sequel.connect config
    end

    callback = app.config.sequel.after_connect
    callback.call if callback.respond_to?(:call)

    db
  end

  class Configuration < ActiveSupport::OrderedOptions

    def self.for(root, database_yml_hash)
      ::SequelRails.configuration ||= begin
        config = new
        config.root = root
        config.raw = database_yml_hash
        config
      end
    end

    def initialize(*)
      super
      self.root = Rails.root
      self.raw = nil
      self.logger = Rails.logger
      self.migration_dir = nil
      self.schema_dump = default_schema_dump
      self.load_database_tasks = true
    end

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

    def default_schema_dump
      not %w(test production).include? Rails.env
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

      # override max connections if requested in app configuration
      config['max_connections'] = max_connections if max_connections
      config['search_path'] = search_path if search_path

      # some adapters only support an url
      if config['adapter'] && config['adapter'] =~ /^(jdbc|do):/ && !config.has_key?('url')
        params = {}
        config.each do |k, v|
          next if ['adapter', 'host', 'port', 'database'].include?(k)
          if k == 'search_path'
            v = v.split(',').map &:strip unless v.is_a? Array
            v = URI::escape(v.join(','))
          end
          params[k] = v
        end
        params_str = params.map { |k, v| "#{k}=#{v}" }.join('&')
        port = config['port'] ? ":#{config['port']}" : ''
        config['url'] ||= case config['adapter']
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
