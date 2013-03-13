require "sequel"

require "rails"
require "active_model/railtie"

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require "action_controller/railtie"

require "sequel_rails/configuration"
require "sequel_rails/migrations"
require "sequel_rails/railties/log_subscriber"
require "sequel_rails/railties/i18n_support"
require "sequel_rails/railties/controller_runtime"
require "sequel_rails/sequel/database/active_support_notification"

module SequelRails

  class Railtie < Rails::Railtie

    ::SequelRails::Railties::LogSubscriber.attach_to :sequel

    config.app_generators.orm :sequel, :migration => true
    config.rails_fancy_pants_logging = true

    config.action_dispatch.rescue_responses.merge!(
      "Sequel::Plugins::RailsExtensions::ModelNotFound" => :not_found,
      "Sequel::ValidationFailed" => :unprocessable_entity,
      "Sequel::NoExistingObject" => :unprocessable_entity
    )
    
    config.sequel = ActiveSupport::OrderedOptions.new

    rake_tasks do
      load "sequel_rails/railties/database.rake"
    end

    initializer 'sequel.configuration' do |app|
      configure_sequel app
    end

    initializer 'sequel.logger' do |app|
      setup_logger app, ::Rails.logger
    end

    initializer 'sequel.i18n_support' do |app|
      setup_i18n_support app
    end

    # Expose database runtime to controller for logging.
    initializer 'sequel.log_runtime' do |app|
      setup_controller_runtime app
    end

    initializer 'sequel.connect' do |app|
      ::SequelRails.setup ::Rails.env
    end

    # Support overwriting crucial steps in subclasses
    def configure_sequel(app)
      app.config.sequel = ::SequelRails::Configuration.for(
        ::Rails.root, app.config.database_configuration
      ).merge!(app.config.sequel)
    end

    def setup_i18n_support(app)
      ::Sequel::Model.send :include, ::SequelRails::I18nSupport
    end

    def setup_controller_runtime(app)
      require 'sequel_rails/railties/controller_runtime'
      ActionController::Base.send :include, SequelRails::Railties::ControllerRuntime
    end

    def setup_logger(app, logger)
      app.config.sequel.logger = logger
    end

  end

end
