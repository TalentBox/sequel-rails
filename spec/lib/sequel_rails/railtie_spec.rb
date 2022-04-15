require 'spec_helper'
require 'helpers/io'

describe SequelRails::Railtie do
  let(:app) { Combustion::Application }

  it 'registers ::Sequel::Railtie::LogSubscriber to receive :sequel notification' do
    expect(
      ActiveSupport::LogSubscriber.log_subscribers.count do |subscriber|
        subscriber.is_a?(SequelRails::Railties::LogSubscriber)
      end
    ).to eq 1
  end

  context 'configures generator to use Sequel' do
    it 'as orm' do
      expect(app.config.generators.options[:rails][:orm]).to be(:sequel)
    end

    it 'for migrations' do
      expect(app.config.generators.options[:sequel][:migration]).to be true
    end
  end

  it 'configures rails to use fancy pants logging' do
    expect(app.config.rails_fancy_pants_logging).to be true
  end

  context "configures action dispatch's rescue responses" do
    let(:rescue_responses) do
      app.config.action_dispatch.rescue_responses
    end

    it 'to handle Sequel::Plugins::RailsExtensions::ModelNotFound with :not_found' do
      expect(rescue_responses['Sequel::Plugins::RailsExtensions::ModelNotFound']).to be(:not_found)
    end

    it 'to handle Sequel::NoMatchingRow with :not_found' do
      expect(rescue_responses['Sequel::NoMatchingRow']).to be(:not_found)
    end

    it 'to handle Sequel::ValidationFailed with :unprocessable_entity' do
      expect(rescue_responses['Sequel::ValidationFailed']).to be(:unprocessable_entity)
    end

    it 'to handle Sequel::NoExistingObject with :unprocessable_entity' do
      expect(rescue_responses['Sequel::NoExistingObject']).to be(:unprocessable_entity)
    end
  end

  it "stores it's own config in app.config.sequel" do
    expect(app.config.sequel).to be_instance_of SequelRails::Configuration
  end

  it 'sets Rails.logger as default logger for its configuration' do
    expect(app.config.sequel.logger).to be Rails.logger
  end

  it 'configures Sequel::Model instances for i18n' do
    expect(User.i18n_scope).to be(:sequel)
    expect(User).to respond_to(:lookup_ancestors)
    expect(User.model_name.human).to eq('translated user')
  end

  it 'adds Sequel runtime to controller for logging' do
    expect(ActionController::Base.included_modules).to include(
      SequelRails::Railties::ControllerRuntime
    )
  end

  it 'configures database in Sequel' do
    expect do
      Sequel::Model.db.test_connection
    end.to_not raise_error
  end

  context 'when database.yml does not exist' do
    before do
      app.config.sequel = ::SequelRails::Configuration.new
    end

    let :configure_sequel! do
      app.configure_for_combustion
      app.config.eager_load = false # to supress a warning
      SequelRails::Railtie.configure_sequel app
      ::SequelRails.setup ::Rails.env
    end

    include IOSpecHelper
    before do
      pretend_file_not_exists(%r{/database.yml$})
    end

    context 'and DATABASE_URL is defined' do
      let :database_url do
        if ENV['TEST_ADAPTER']=~/sqlite/
          'sqlite:/' # in-memory db
        else
          cfg = Combustion::Application.config.database_configuration['test']
          SequelRails::DbConfig.new(cfg).url
        end
      end

      around do |ex|
        orig = ENV['DATABASE_URL']
        ENV['DATABASE_URL'] = database_url
        ex.run
        ENV['DATABASE_URL'] = orig
      end

      it 'initializing the application uses it' do
        expect do
          configure_sequel!
          Sequel::Model.db.test_connection
        end.to_not raise_error
      end
    end

    context 'and DATABASE_URL is not defined' do
      around do |ex|
        orig = ENV['DATABASE_URL']
        ENV.delete 'DATABASE_URL'
        ex.run
        ENV['DATABASE_URL'] = orig
      end

      it 'initializing the application fails' do
        expect do
          configure_sequel!
        end.to raise_error RuntimeError, "Database not configured.\nPlease create config/database.yml or set DATABASE_URL in environment."
      end
    end
  end

  it 'run load hooks for :sequel passing ::Sequel::Model' do
    class_context = nil
    ::ActiveSupport.on_load :sequel do
      class_context = self
    end
    app
    expect(class_context).to be ::Sequel::Model
  end
end
