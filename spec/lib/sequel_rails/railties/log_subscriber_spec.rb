require 'spec_helper'
require 'active_support/log_subscriber/test_helper'

describe SequelRails::Railties::LogSubscriber do
  include ActiveSupport::LogSubscriber::TestHelper
  def set_logger(logger) # rubocop:disable AccessorMethodName
    SequelRails.configuration.logger = logger
    ActiveSupport::LogSubscriber.logger = logger
  end
  before do
    setup
    described_class.attach_to :sequel
    described_class.reset_count
  end
  after { teardown }

  it 'does not log query when logger level is not debug, but track runtime and count' do
    expect(described_class.count).to eq 0
    @logger.level = defined?(Logger::Severity) ? Logger::Severity::INFO : :info
    User.all
    wait
    expect(@logger.logged(:debug).size).to eq 0
    expect(described_class.count).to be > 0
  end

  describe 'for postgresql', :postgres do
    it 'logs queries, runtime and count' do
      expect(described_class.count).to eq 0
      User.all
      User.where(:id => 1).select_map(:id)
      wait
      expect(@logger.logged(:debug)[-2]).to match(/SELECT \* FROM "users"/)
      expect(@logger.logged(:debug)[-1]).to match(/SELECT "id" FROM "users" WHERE \("id" = 1\)/)
      expect(described_class.count).to be > 0
    end

    it 'works with bound variables' do
      ds = Sequel::Model.db[:users].where(:id => :$id)
      ds.call(:select, :id => 1)
      wait
      expect(@logger.logged(:debug).last).to match(
        /SELECT \* FROM "users" WHERE \("id" = \$1\) \[1\]/
      )
      expect(described_class.count).to be > 0
    end

    it 'works with prepared statements' do
      ds = Sequel::Model.db[:users].where(:id => :$id).prepare(:select, :users_by_id)
      ds.call(:id => 1)
      wait
      expect(@logger.logged(:debug)[-2]).to match(
        /PREPARE users_by_id AS SELECT \* FROM "users" WHERE \("id" = \$1\)/
      )
      expect(@logger.logged(:debug)[-1]).to match(
        /EXECUTE users_by_id \[1\]/
      )
      expect(described_class.count).to be > 0
    end
  end

  describe 'for mysql', :mysql do
    it 'logs queries, runtime and count' do
      expect(described_class.count).to eq 0
      User.all
      User.where(:id => 1).select_map(:id)
      wait
      expect(@logger.logged(:debug)[-2]).to match(/SELECT \* FROM `users`/)
      expect(@logger.logged(:debug)[-1]).to match(/SELECT `id` FROM `users` WHERE \(`id` = 1\)/)
      expect(described_class.count).to be > 0
    end

    it 'works with plain queries', :mysql do
      Sequel::Model.db[:users].where(:id => 1).to_a
      wait
      expect(@logger.logged(:debug).last).to match(
        /SELECT \* FROM `users` WHERE \(`id` = 1\)/
      )
      expect(described_class.count).to be > 0
    end

    it 'works with bound variables' do
      ds = Sequel::Model.db[:users].where(:id => :$id)
      ds.call(:select, :id => 1)
      wait
      expect(@logger.logged(:debug).last).to match(
        /Executing SELECT \* FROM `users` WHERE \(`id` = \?\) \[1\]/
      )
      expect(described_class.count).to be > 0
    end

    it 'works with prepared statements' do
      ds = Sequel::Model.db[:users].where(:id => :$id).prepare(:select, :users_by_id)
      ds.call(:id => 1)
      wait
      expect(@logger.logged(:debug)[-2]).to match(
        /Preparing users_by_id: SELECT \* FROM `users` WHERE \(`id` = \?\)/
      )
      expect(@logger.logged(:debug)[-1]).to match(
        /Executing users_by_id \[1\]/
      )
      expect(described_class.count).to be > 0
    end
  end

  describe 'for sqlite', :sqlite do
    it 'logs queries, runtime and count' do
      expect(described_class.count).to eq 0
      User.all
      User.where(:id => 1).select_map(:id)
      wait
      expect(@logger.logged(:debug)[-2]).to match(/SELECT \* FROM `users`/)
      expect(@logger.logged(:debug)[-1]).to match(/SELECT `id` FROM `users` WHERE \(`id` = 1\)/)
      expect(described_class.count).to be > 0
    end

    it 'works with plain queries', :mysql do
      Sequel::Model.db[:users].where(:id => 1).to_a
      wait
      expect(@logger.logged(:debug).last).to match(
        /SELECT \* FROM `users` WHERE \(`id` = 1\)/
      )
      expect(described_class.count).to be > 0
    end

    it 'works with bound variables' do
      ds = Sequel::Model.db[:users].where(:id => :$id)
      ds.call(:select, :id => 1)
      wait
      expect(@logger.logged(:debug).last).to match(
        /SELECT \* FROM `users` WHERE \(`id` = :id\) {"id"=>1}/
      )
      expect(described_class.count).to be > 0
    end

    it 'works with prepared statements' do
      ds = Sequel::Model.db[:users].where(:id => :$id).prepare(:select, :users_by_id)
      ds.call(:id => 1)
      wait
      expect(@logger.logged(:debug)[-2]).to match(
        /PREPARE users_by_id: SELECT \* FROM `users` WHERE \(`id` = :id\)/
      )
      expect(@logger.logged(:debug)[-1]).to match(
        /EXECUTE users_by_id {"id"=>1}/
      )
      expect(described_class.count).to be > 0
    end
  end
end
