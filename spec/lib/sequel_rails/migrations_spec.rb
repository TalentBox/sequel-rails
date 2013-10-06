require "spec_helper"
require "fakefs/spec_helpers"

describe SequelRails::Migrations do
  let!(:db) { ::Sequel::Model.db }

  [:migrate_up!, :migrate_down!].each do |migration_method|
    describe ".#{migration_method}" do
      let(:result) { mock :result }
      context "with no version specified" do
        let(:opts) { {} }
        it "runs migrations using Sequel::Migrator" do
          ::Sequel::Migrator.should_receive(:run).with(
            db, Rails.root.join("db/migrate"), opts
          ).and_return result
          described_class.send(migration_method).should be result
        end
      end
      context "with version specified" do
        let(:opts) { {:target => 1} }
        it "runs migrations using Sequel::Migrator" do
          ::Sequel::Migrator.should_receive(:run).with(
            db, Rails.root.join("db/migrate"), opts
          ).and_return result
          described_class.send(migration_method, 1).should be result
        end
      end
    end
  end

  describe ".pending_migrations?" do
    include FakeFS::SpecHelpers
    let(:path) { Rails.root.join("db/migrate") }

    it "returns false if no db/migrate directory exists" do
      described_class.pending_migrations?.should == false
    end

    it "returns false if db/migrate directory exists, but is empty" do
      FileUtils.mkdir_p path
      described_class.pending_migrations?.should == false
    end

    context "when db/migrate directory exists and contains migrations" do
      before do
        FileUtils.mkdir_p path
        FileUtils.touch(File.join(path, 'test_migration.rb'))
      end

      it "returns true if any pending migration" do
        ::Sequel::Migrator.should_receive(:is_current?).with(
          db, Rails.root.join("db/migrate")
        ).and_return false
        described_class.pending_migrations?.should == true
      end

      it "returns false if no pending migration" do
        ::Sequel::Migrator.should_receive(:is_current?).with(
          db, Rails.root.join("db/migrate")
        ).and_return true
        described_class.pending_migrations?.should == false
      end
    end
  end
end
