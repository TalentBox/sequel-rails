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
require 'sequel_rails/railties/controller_runtime'
require 'sequel_rails/sequel/database/active_support_notification'
require 'sequel_rails/sequel/model'
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
      load 'sequel_rails/railties/database.rake' if app.config.sequel.load_database_tasks
    end

    initializer 'sequel.configuration' do |app|
      configure_sequel app
    end

    initializer 'sequel.logger' do |app|
      setup_logger app, ::Rails.logger
    end

    initializer 'sequel.i18n_support' do |_app|
      setup_i18n_support
    end

    # Expose database runtime to controller for logging.
    initializer 'sequel.log_runtime' do |_app|
      setup_controller_runtime
    end

    initializer 'sequel.connect' do |_app|
      ::SequelRails.setup ::Rails.env
    end

    # Support overwriting crucial steps in subclasses
    def configure_sequel(app)
      app.config.sequel.merge!(
        :root => ::Rails.root,
        :raw => app.config.database_configuration
      )
      ::SequelRails.configuration = app.config.sequel
    end

    def setup_i18n_support
      ::Sequel::Model.send :include, ::SequelRails::I18nSupport
    end

    def setup_controller_runtime
      require 'sequel_rails/railties/controller_runtime'
      ActionController::Base.send :include, SequelRails::Railties::ControllerRuntime
    end

    def setup_logger(app, logger)
      app.config.sequel.logger = logger
    end
  end
end
