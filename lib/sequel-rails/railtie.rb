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

require 'sequel-rails/setup'
require 'sequel-rails/railties/log_subscriber'
require 'sequel-rails/railties/i18n_support'


module Rails
  module Sequel

    class Railtie < Rails::Railtie

      ::Sequel::Railties::LogSubscriber.attach_to :sequel

      config.app_generators.orm :sequel, :migration => true
      config.rails_fancy_pants_logging = true

      config.action_dispatch.rescue_responses.merge!(
        'Sequel::Plugins::RailsExtensions::ModelNotFound' => :not_found,
        'Sequel::ValidationFailed'                        => :unprocessable_entity,
        'Sequel::NoExistingObject'                        => :unprocessable_entity
      )

      rake_tasks do
        load 'sequel-rails/railties/database.rake'
      end

      initializer 'sequel.configuration' do |app|
        configure_sequel(app)
      end

      initializer 'sequel.logger' do |app|
        setup_logger(app, Rails.logger)
      end

      initializer 'sequel.i18n_support' do |app|
        setup_i18n_support(app)
      end

      # Expose database runtime to controller for logging.
      initializer 'sequel.log_runtime' do |app|
        setup_controller_runtime(app)
      end

      initializer 'sequel.connect' do |app|
        Rails::Sequel.setup(Rails.env)
      end

      # Run setup code after_initialize to make sure all config/initializers
      # are in effect once we setup the connection. This is especially necessary
      # for the cascaded adapter wrappers that need to be declared before setup.
      config.after_initialize do |app|
        ::Sequel::Model.plugin :active_model
        ::Sequel::Model.plugin :validation_helpers
        ::Sequel::Model.plugin :rails_extensions
        ::Sequel::Model.raise_on_save_failure = false
      end

      # Support overwriting crucial steps in subclasses
      def configure_sequel(app)
        app.config.sequel = Rails::Sequel::Configuration.for(
          Rails.root, app.config.database_configuration
        )
      end

      def setup_i18n_support(app)
        ::Sequel::Model.send :include, Rails::Sequel::I18nSupport
      end

      def setup_controller_runtime(app)
        require 'sequel-rails/railties/controller_runtime'
        ActionController::Base.send :include, Rails::Sequel::Railties::ControllerRuntime
      end

      def setup_logger(app, logger)
        app.config.sequel.logger=logger
      end

    end

  end
end
