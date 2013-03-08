require "spec_helper"

describe SequelRails::Configuration do

  let(:environments) do
    {
      "development" => {
        "adapter" => "postgres",
        "owner" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "username" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "database" => "sequel_rails_test_storage_dev",
        "host" => "127.0.0.1",
      },
      "test" => {
        "adapter" => "postgres",
        "owner" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "username" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "database" => "sequel_rails_test_storage_test",
        "host" => "127.0.0.1",
      },
      "remote" => {
        "adapter" => "mysql",
        "host" => "10.0.0.1",
        "database" => "sequel_rails_test_storage_remote",
      },
      "production" => {
        "host" => "10.0.0.1",
        "database" => "sequel_rails_test_storage_production",
      },
      "bogus" => {},
    }
  end

  before do
    SequelRails.configuration.stub(:raw).and_return environments
    SequelRails.configuration.instance_variable_set('@environments', nil)
    ENV['RUBY_VERSION'], @_ruby_version = ruby_version, ENV['RUBY_VERSION']
  end

  after do
    ENV['RUBY_VERSION'] = @_ruby_version
  end

  subject { SequelRails.setup(environment) }

  describe ".setup" do

    context "for a postgres connection" do

      let(:environment) { 'development' }

      context "in C-Ruby" do

        let(:ruby_version) { 'ruby-1.9.3' }

        it "produces a sane config without url" do
          ::Sequel.should_receive(:connect) do |hash|
            hash['adapter'].should == 'postgres'
          end
          subject
        end
      end

      context "in JRuby" do

        let(:ruby_version) { 'jruby-1.7.3' }

        it "produces an adapter config with a url" do
          ::Sequel.should_receive(:connect) do |url, hash|
            url.should =~ /^jdbc:postgresql:\/\//
            hash['adapter'].should == 'jdbc:postgresql'
            hash['host'].should    == '127.0.0.1'
          end
          subject
        end
      end
    end

    context "for a mysql connection" do

      let(:environment) { 'remote' }

      context "in C-Ruby" do

        let(:ruby_version) { 'ruby-1.9.3' }

        it "produces a config without url" do
          ::Sequel.should_receive(:connect) do |hash|
            hash['adapter'].should == 'mysql'
          end
          subject
        end
      end

      context "in JRuby" do

        let(:ruby_version) { 'jruby-1.7.3' }

        it "produces a jdbc mysql config" do
          ::Sequel.should_receive(:connect) do |url, hash|
            url.should =~ /^jdbc:mysql:\/\//
            hash['adapter'].should  == 'jdbc:mysql'
            hash['database'].should == 'sequel_rails_test_storage_remote'
          end
          subject
        end
      end
    end
  end
end
