require 'sequel'

require 'rails'
require 'active_model/railtie'

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require 'action_controller/railtie'

require 'sequel_rails/configuration'
require 'sequel_rails/migrations'
require 'sequel_rails/railties/log_subscriber'
require 'sequel_rails/railties/i18n_support'
require 'sequel_rails/railties/spring_support'
require 'sequel_rails/railties/controller_runtime'
require 'sequel_rails/sequel/database/active_support_notification'
require 'action_dispatch/middleware/session/sequel_store'

module SequelRails
  class Railtie < Rails::Railtie
    ::SequelRails::Railties::LogSubscriber.attach_to :sequel

    config.app_generators.orm :sequel, :migration => true
    config.rails_fancy_pants_logging = true

    config.action_dispatch.rescue_responses.merge!(
      'Sequel::Plugins::RailsExtensions::ModelNotFound' => :not_found,
      'Sequel::NoMatchingRow' => :not_found,
      'Sequel::ValidationFailed' => :unprocessable_entity,
      'Sequel::NoExistingObject' => :unprocessable_entity
    )

    config.sequel = ::SequelRails::Configuration.new

    rake_tasks do |app|
      load_tasks_config = app.config.sequel.load_database_tasks

      SequelRails::TASK_NAMESPACE =
        case load_tasks_config
        when Symbol, String then load_tasks_config.to_sym
        else :db
        end

      load 'sequel_rails/railties/database.rake' if load_tasks_config

      check_skip_connect_conditions(app)
    end

    initializer 'sequel.load_hooks' do
      ::ActiveSupport.run_load_hooks(:sequel, ::Sequel::Model)
    end

    initializer 'sequel.configuration' do |app|
      configure_sequel app
    end

    initializer 'sequel.logger' do |app|
      app.config.sequel.logger ||= ::Rails.logger
    end

    initializer 'sequel.i18n_support' do |_app|
      setup_i18n_support
    end

    # Expose database runtime to controller for logging.
    initializer 'sequel.log_runtime' do |_app|
      setup_controller_runtime
    end

    initializer 'sequel.connect' do |app|
      ::SequelRails.setup(::Rails.env) if database_connection_required?(app)
    end

    initializer 'sequel.spring' do |_app|
      if defined?(::Spring::Application)
        class ::Spring::Application # rubocop:disable Style/ClassAndModuleChildren
          include ::SequelRails::SpringSupport
          alias_method :disconnect_database_without_sequel, :disconnect_database
          alias_method :disconnect_database, :disconnect_database_with_sequel
        end
      end
    end

    # Support overwriting crucial steps in subclasses
    def configure_sequel(app)
      rails_db_config = begin
        app.config.database_configuration
      rescue Errno::ENOENT
        {} # will try to use DATABASE_URL
      end

      app.config.sequel.merge!(
        :root => ::Rails.root,
        :raw => rails_db_config
      )
      ::SequelRails.configuration = app.config.sequel
    end

    def setup_i18n_support
      ::Sequel::Model.send :extend, ::ActiveModel::Translation
      ::Sequel::Model.send :extend, ::SequelRails::I18nSupport
    end

    def setup_controller_runtime
      require 'sequel_rails/railties/controller_runtime'
      ActionController::Base.send :include, SequelRails::Railties::ControllerRuntime
    end

    def check_skip_connect_conditions(app)
      app.config.sequel[:skip_connect] ||= command_requiring_no_connection?
    end

    def database_connection_required?(app)
      !app.config.sequel[:skip_connect]
    end

    def command_requiring_no_connection?
      no_connection_commands = ["db:create", "db:drop"]

      ARGV.any? { |item| no_connection_commands.include?(item) }
    end
  end
end
