require "spec_helper"

describe SequelRails::Railtie do
  it "registers ::Sequel::Railtie::LogSubscriber to receive :sequel notification" do
    ActiveSupport::LogSubscriber.log_subscribers.select do |subscriber|
      subscriber.is_a?(SequelRails::Railties::LogSubscriber)
    end.should have(1).item
  end

  context "configures generator to use Sequel" do
    it "as orm" do
      Combustion::Application.config.generators.options[:rails][:orm].should == :sequel
    end

    it "for migrations" do
      Combustion::Application.config.generators.options[:sequel][:migration].should be true
    end
  end

  it "configures rails to use fancy pants logging" do
    Combustion::Application.config.rails_fancy_pants_logging.should be true
  end

  context "configures action dispatch's rescue responses" do
    let(:rescue_responses) do
      Combustion::Application.config.action_dispatch.rescue_responses
    end

    it "to handle Sequel::Plugins::RailsExtensions::ModelNotFound with :not_found" do
      rescue_responses["Sequel::Plugins::RailsExtensions::ModelNotFound"].should == :not_found
    end

    it "to handle Sequel::ValidationFailed with :unprocessable_entity" do
      rescue_responses["Sequel::ValidationFailed"].should == :unprocessable_entity
    end

    it "to handle Sequel::NoExistingObject with :unprocessable_entity" do
      rescue_responses["Sequel::NoExistingObject"].should == :unprocessable_entity
    end
  end

  it "adds it's own database's rake tasks" do
    pending "need to find a way to spec it"
  end

  it "stores it's own config in app.config.sequel" do
    Combustion::Application.config.sequel.should be_instance_of SequelRails::Configuration
  end

  it "sets Rails.logger as default logger for its configuration" do
    Combustion::Application.config.sequel.logger.should be Rails.logger
  end

  it "configures Sequel::Model instances for i18n" do
    User.new.i18n_scope.should == :sequel
  end

  it "adds Sequel runtime to controller for logging" do
    ActionController::Base.included_modules.should include(
      SequelRails::Railties::ControllerRuntime
    )
  end

  context "Sequel::Model is configured" do
    let(:plugins) { Sequel::Model.plugins }
    it "to use :active_model plugin" do
      plugins.should include Sequel::Plugins::ActiveModel
    end
    it "to use :validation_helpers plugin" do
      plugins.should include Sequel::Plugins::ValidationHelpers
    end
    it "to use :rails_extensions plugin" do
      plugins.should include Sequel::Plugins::RailsExtensions
    end
  end

  it "configures database in Sequel" do
    expect do
      Sequel::Model.db.test_connection
    end.to_not raise_error Sequel::Error
  end
end
