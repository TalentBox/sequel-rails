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

  it 'logs queries, runtime and count' do
    expect(described_class.count).to eq 0
    User.all
    wait
    expect(@logger.logged(:debug).last).to match(/SELECT \* FROM ("|`)users("|`)/)
    expect(described_class.count).to be > 0
  end

  it 'does not log query when logger level is not debug, but track runtime and count' do
    expect(described_class.count).to eq 0
    @logger.level = defined?(Logger::Severity) ? Logger::Severity::INFO : :info
    User.all
    wait
    expect(@logger.logged(:debug).size).to eq 0
    expect(described_class.count).to be > 0
  end

  it 'works with bound variables' do
    ds = Sequel::Model.db[:users].where(:id => :$id)
    ds.call(:select, :id => 1)
    expect(@logger.logged(:debug).last).to match(
      /SELECT \* FROM "users" WHERE \("id" = \$1\) \[1\]/
    )
  end

  it 'works with prepared statements' do
    ds = Sequel::Model.db[:users].where(:id => :$id).prepare(:select, :users_by_id)
    ds.call(:id => 1)
    expect(@logger.logged(:debug)[-2]).to match(
      /PREPARE users_by_id AS SELECT \* FROM "users" WHERE \("id" = \$1\)/
    )
    expect(@logger.logged(:debug)[-1]).to match(
      /EXECUTE users_by_id \[1\]/
    )
  end
end
