require 'spec_helper'

describe SequelRails do
  describe '.setup' do
    let(:environment) { 'development' }
    let(:configuration) { SequelRails::Configuration.new }

    it 'delegates to current configuration' do
      SequelRails.configuration = configuration
      expect(configuration).to receive(:connect).with(environment)
      SequelRails.setup environment
    end
  end
end

describe SequelRails::Configuration do
  describe '#schema_dump' do
    before { allow(Rails).to receive(:env).and_return(environment) }
    subject { described_class.new }

    context 'in test environment' do
      let(:environment) { 'test' }
      it 'defaults to false' do
        expect(subject.schema_dump).to be false
      end
      it 'can be assigned' do
        subject.schema_dump = true
        expect(subject.schema_dump).to be true
      end
      it 'can be set from merging another hash' do
        subject.merge!(:schema_dump => true)
        expect(subject.schema_dump).to be true
      end
    end

    context 'in production environment' do
      let(:environment) { 'production' }
      it 'defaults to false' do
        expect(subject.schema_dump).to be false
      end
      it 'can be assigned' do
        subject.schema_dump = true
        expect(subject.schema_dump).to be true
      end
      it 'can be set from merging another hash' do
        subject.merge!(:schema_dump => true)
        expect(subject.schema_dump).to be true
      end
    end

    context 'in other environments' do
      let(:environment) { 'development' }
      it 'defaults to true' do
        expect(subject.schema_dump).to be true
      end
      it 'can be assigned' do
        subject.schema_dump = false
        expect(subject.schema_dump).to be false
      end
      it 'can be set from merging another hash' do
        subject.merge!(:schema_dump => false)
        expect(subject.schema_dump).to be false
      end
    end
  end

  describe '#load_database_tasks' do
    subject { described_class.new }

    it 'defaults to true' do
      expect(subject.load_database_tasks).to be true
    end
    it 'can be assigned' do
      subject.load_database_tasks = false
      expect(subject.load_database_tasks).to be false
    end
    it 'can be set from merging another hash' do
      subject.merge!(:load_database_tasks => false)
      expect(subject.load_database_tasks).to be false
    end
  end

  describe '#skip_connect' do
    subject { described_class.new }

    it 'defaults to nil' do
      expect(subject.skip_connect).to be nil
    end
    it 'can be assigned' do
      subject.skip_connect = true
      expect(subject.skip_connect).to be true
    end
    it 'can be set from merging another hash' do
      subject.merge!(:skip_connect => true)
      expect(subject.skip_connect).to be true
    end
  end

  describe '#test_connect' do
    it 'defaults to true' do
      expect(subject.test_connect).to be true
    end

    it 'can be assigned' do
      subject.test_connect = true
      expect(subject.test_connect).to be true
    end

    it 'can be set from merging another hash' do
      subject.merge!(:test_connect => true)
      expect(subject.test_connect).to be true
    end
  end

  describe '#connect' do
    let(:environments) do
      {
        'development' => {
          'adapter' => (ENV['TEST_ADAPTER'] || 'postgres'),
          'owner' => (ENV['TEST_OWNER'] || ENV['USER']),
          'username' => (ENV['TEST_OWNER'] || ENV['USER']),
          'database' => 'sequel_rails_test_storage_dev',
          'password' => ENV['TEST_PASSWORD'],
          'host' => '127.0.0.1',
        },
        'test' => {
          'adapter' => (ENV['TEST_ADAPTER'] || 'postgres'),
          'owner' => (ENV['TEST_OWNER'] || ENV['USER']),
          'username' => (ENV['TEST_OWNER'] || ENV['USER']),
          'database' => 'sequel_rails_test_storage_test',
          'password' => ENV['TEST_PASSWORD'],
          'host' => '127.0.0.1',
        },
        'remote' => {
          'adapter' => 'mysql',
          'host' => '10.0.0.1',
          'database' => 'sequel_rails_test_storage_remote',
        },
        'production' => {
          'host' => '10.0.0.1',
          'database' => 'sequel_rails_test_storage_production',
        },
        'url_already_constructed' => {
          'adapter' => 'adaptername',
          'url' => 'jdbc:adaptername://HOST/DB?user=U&password=P&ssl=true&sslfactory=sslFactoryOption'
        },
        'bogus' => {},
      }
    end

    subject { described_class.new.tap { |config| config.raw = environments } }

    context 'when stubbing SequelRails.jruby?' do
      before { allow(SequelRails).to receive(:jruby?).and_return(is_jruby) }

      shared_examples 'test_connect' do
        context 'test_connect' do
          it 'passes the value' do
            expect(::Sequel).to receive(:connect) do |hash_or_url, *_|
              if hash_or_url.is_a? Hash
                expect(hash_or_url[:test]).to eq true
              else
                expect(hash_or_url).to include('test=true')
              end
            end

            subject.connect environment
          end
        end
      end

      shared_examples 'max_connections' do
        context 'with max_connections=7 config option' do
          let(:max_connections) { 31_337 }
          before do
            environments[environment]['max_connections'] = 7
            subject.max_connections = max_connections
          end

          it 'overrides the option from the configuration' do
            expect(::Sequel).to receive(:connect) do |hash_or_url, *_|
              if hash_or_url.is_a? Hash
                expect(hash_or_url[:max_connections]).to eq(max_connections)
              else
                expect(hash_or_url).to include("max_connections=#{max_connections}")
              end
            end
            subject.connect environment
          end
        end

        context 'with pool configuration key' do
          before do
            environments[environment]['pool'] = 7
          end
          it 'uses the value' do
            expect(::Sequel).to receive(:connect) do |hash_or_url, *_|
              if hash_or_url.is_a? Hash
                expect(hash_or_url[:max_connections]).to eq(7)
              else
                expect(hash_or_url).to include('max_connections=7')
              end
            end
            subject.connect environment
          end
        end
      end

      shared_examples 'servers' do
        context 'servers' do
          let(:servers) { { read_only: { host: 'replica' } } }

          shared_examples 'passes the value only through options hash' do
            it 'passes the value only through options hash' do
              expect(::Sequel).to receive(:connect) do |hash_or_url, *_|
                if hash_or_url.is_a? Hash
                  servers.keys.each do |k|
                    expect(hash_or_url[:servers][k]).to eq servers[k]
                  end
                else
                  puts hash_or_url
                  expect(hash_or_url).not_to include('servers=')
                end
              end
              subject.connect environment
            end
          end

          context 'with servers set in config' do
            before do
              subject.servers = servers
            end

            include_examples 'passes the value only through options hash'
          end

          context 'with servers set in environment' do
            before do
              environments[environment]['servers'] = servers
            end

            include_examples 'passes the value only through options hash'
          end
        end
      end

      shared_examples 'with DATABASE_URL in ENV' do
        let(:database_url) { 'adapter://user:pass@host/db' }
        def with_database_url_env
          previous, ENV['DATABASE_URL'] = ENV['DATABASE_URL'], database_url
          yield
          ENV['DATABASE_URL'] = previous
        end

        context 'with DATABASE_URL in ENV' do
          around do |example|
            with_database_url_env { example.call }
          end

          shared_examples 'uses DATABASE_URL' do
            it 'uses DATABASE_URL' do
              expect(::Sequel).to receive(:connect) do |url, _hash|
                expect(url).to eq database_url
              end
              subject.connect environment
            end
          end

          context 'without url set in config' do
            include_examples 'uses DATABASE_URL'
          end

          context 'without config' do
            before do
              environments.delete environment
            end
            include_examples 'uses DATABASE_URL'
          end

          context 'with url set in config' do
            let(:config_url) { 'another_adapter://user:pass@host/db' }
            around do |example|
              with_database_url_env do
                environments[environment]['url'] = config_url
                example.call
              end
            end
            it 'uses url from config' do
              expect(::Sequel).to receive(:connect) do |url, _hash|
                expect(url).to eq config_url
              end
              subject.connect environment
            end
          end
        end
      end

      context 'for a postgres connection' do
        shared_examples 'search_path' do
          context 'with search_path config option' do
            let(:search_path) { %w(secret private public) }
            before do
              environments[environment]['search_path'] = 'private, public'
              subject.search_path = search_path
            end

            it 'overrides the option from the configuration' do
              expect(::Sequel).to receive(:connect) do |hash_or_url, *_|
                if hash_or_url.is_a? Hash
                  expect(hash_or_url[:search_path]).to eq(search_path)
                else
                  expect(hash_or_url).to include('search_path=secret%2Cprivate%2Cpublic')
                end
              end
              subject.connect environment
            end
          end
        end

        let(:environment) { 'development' }

        context 'in C-Ruby' do
          include_examples 'test_connect'
          include_examples 'max_connections'
          include_examples 'search_path'
          include_examples 'servers'
          include_examples 'with DATABASE_URL in ENV'

          let(:is_jruby) { false }

          it 'produces a sane config without url' do
            expect(::Sequel).to receive(:connect) do |hash|
              expect(hash[:adapter]).to eq('postgres')
            end
            subject.connect environment
          end
        end

        context 'in JRuby' do
          include_examples 'test_connect'
          include_examples 'max_connections'
          include_examples 'search_path'
          include_examples 'servers'
          include_examples 'with DATABASE_URL in ENV'

          let(:is_jruby) { true }

          it 'produces an adapter config with a url' do
            expect(::Sequel).to receive(:connect) do |url, hash|
              expect(url).to start_with('jdbc:postgresql://')
              expect(hash[:adapter]).to eq('jdbc:postgresql')
              expect(hash[:host]).to eq('127.0.0.1')
            end
            subject.connect environment
          end

          context 'when url is already given' do
            let(:environment) { 'url_already_constructed' }

            it 'does not change the url' do
              expect(::Sequel).to receive(:connect) do |url, hash|
                expect(url).to eq('jdbc:adaptername://HOST/DB?user=U&password=P&ssl=true&sslfactory=sslFactoryOption')
                expect(hash[:adapter]).to eq('jdbc:adaptername')
              end
              subject.connect environment
            end
          end
        end
      end

      context 'for a mysql connection' do
        let(:environment) { 'remote' }

        context 'in C-Ruby' do
          include_examples 'test_connect'
          include_examples 'max_connections'
          include_examples 'servers'
          include_examples 'with DATABASE_URL in ENV'

          let(:is_jruby) { false }

          it 'produces a config without url' do
            expect(::Sequel).to receive(:connect) do |hash|
              expect(hash[:adapter]).to eq('mysql')
            end
            subject.connect environment
          end
        end

        context 'in JRuby' do
          include_examples 'test_connect'
          include_examples 'max_connections'
          include_examples 'servers'
          include_examples 'with DATABASE_URL in ENV'

          let(:is_jruby) { true }

          it 'produces a jdbc mysql config' do
            expect(::Sequel).to receive(:connect) do |url, hash|
              expect(url).to start_with('jdbc:mysql://')
              expect(hash[:adapter]).to eq('jdbc:mysql')
              expect(hash[:database]).to eq('sequel_rails_test_storage_remote')
            end
            subject.connect environment
          end

          context 'when url is already given' do
            let(:environment) { 'url_already_constructed' }

            it 'does not change the url' do
              expect(::Sequel).to receive(:connect) do |url, hash|
                expect(url).to eq('jdbc:adaptername://HOST/DB?user=U&password=P&ssl=true&sslfactory=sslFactoryOption')
                expect(hash[:adapter]).to eq('jdbc:adaptername')
              end
              subject.connect environment
            end
          end
        end
      end
    end

    describe 'after connect hook' do
      let(:hook) { double }
      let(:environment) { 'development' }

      it 'runs hook if provided' do
        subject.after_connect = hook
        expect(hook).to receive(:call)
        subject.connect environment
      end
    end

    describe 'after each connection hook' do
      let(:hook) { double }
      let(:environment) { 'development' }

      it 'runs hook if provided' do
        subject.after_new_connection = hook
        expect(hook).to receive(:call)
        subject.connect environment
      end
    end
  end
end
