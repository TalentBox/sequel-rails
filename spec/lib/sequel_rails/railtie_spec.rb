require "spec_helper"

describe SequelRails::Railtie do
  let(:app) { Combustion::Application }

  it "registers ::Sequel::Railtie::LogSubscriber to receive :sequel notification" do
    ActiveSupport::LogSubscriber.log_subscribers.select do |subscriber|
      subscriber.is_a?(SequelRails::Railties::LogSubscriber)
    end.should have(1).item
  end

  context "configures generator to use Sequel" do
    it "as orm" do
      app.config.generators.options[:rails][:orm].should == :sequel
    end

    it "for migrations" do
      app.config.generators.options[:sequel][:migration].should be true
    end
  end

  it "configures rails to use fancy pants logging" do
    app.config.rails_fancy_pants_logging.should be true
  end

  context "configures action dispatch's rescue responses" do
    let(:rescue_responses) do
      app.config.action_dispatch.rescue_responses
    end

    it "to handle Sequel::Plugins::RailsExtensions::ModelNotFound with :not_found" do
      rescue_responses["Sequel::Plugins::RailsExtensions::ModelNotFound"].should == :not_found
    end

    it "to handle Sequel::NoMatchingRow with :not_found" do
      rescue_responses["Sequel::NoMatchingRow"].should == :not_found
    end

    it "to handle Sequel::ValidationFailed with :unprocessable_entity" do
      rescue_responses["Sequel::ValidationFailed"].should == :unprocessable_entity
    end

    it "to handle Sequel::NoExistingObject with :unprocessable_entity" do
      rescue_responses["Sequel::NoExistingObject"].should == :unprocessable_entity
    end
  end

  it "stores it's own config in app.config.sequel" do
    app.config.sequel.should be_instance_of SequelRails::Configuration
  end

  it "sets Rails.logger as default logger for its configuration" do
    app.config.sequel.logger.should be Rails.logger
  end

  it "configures Sequel::Model instances for i18n" do
    User.new.i18n_scope.should == :sequel
  end

  it "adds Sequel runtime to controller for logging" do
    ActionController::Base.included_modules.should include(
      SequelRails::Railties::ControllerRuntime
    )
  end

  it "configures database in Sequel" do
    expect do
      Sequel::Model.db.test_connection
    end.to_not raise_error Sequel::Error
  end
end
