begin
  require 'bundler/setup'
rescue LoadError
  warn 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'sequel_rails'

begin
  require 'rspec/core/rake_task'

  desc 'Run RSpec code example (default to only PostgreSQL)'
  RSpec::Core::RakeTask.new

  namespace :spec do
    def clean_env
      %w(
        TEST_ADAPTER
        TEST_DATABASE
        TEST_DATABASE_HOST
        TEST_OWNER
        TEST_USERNAME
        TEST_PASSWORD
        TEST_ENCODING
      ).each do |name|
        ENV[name] = nil
      end
    end

    configs = {
      'postgresql' => { 'TEST_ENCODING' => 'unicode' },
      'sqlite3'    => { 'TEST_DATABASE' => File.join(File.expand_path('.'), 'spec/internal/db/database.sqlite3') },
    }

    configs.merge!(
      'mysql' => { 'TEST_ENCODING' => 'utf8', 'TEST_USERNAME' => 'root' }
    ) if RUBY_VERSION < '2.4'

    configs.merge!(
      'mysql2' => { 'TEST_ENCODING' => 'utf8', 'TEST_USERNAME' => 'root', 'TEST_DATABASE' => 'sequel_rails_test_mysql2' }
    ) unless SequelRails.jruby?

    configs.each do |adapter, config|
      desc "Run specs for #{adapter} adapter"
      task adapter do
        puts "running spec:#{adapter}"
        clean_env
        ENV['TEST_ADAPTER'] = adapter
        config.each do |key, value|
          ENV[key] = value
        end
        rake = ENV['RAKE'] || "#{FileUtils::RUBY} -S rake"
        sh "#{rake} spec 2>&1"
      end
    end

    desc 'Run specs for all adapters'
    task :all do
      configs.keys.map { |adapter| Rake::Task["spec:#{adapter}"].invoke }.all?
    end
  end

  begin
    require 'rubocop/rake_task'

    RuboCop::RakeTask.new do |task|
      task.patterns = ['-R']
    end
  rescue LoadError
    task :rubocop do
      abort 'rubocop is not available. In order to run rubocop, you must: bundle install'
    end
  end

  task :default do
    Rake::Task['spec:all'].invoke
    Rake::Task['rubocop'].invoke if defined?(Rubocop)
  end

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: bundle install'
  end
end
