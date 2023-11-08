require 'spec_helper'

describe 'Database rake tasks', :no_transaction => true do
  let(:app) { Combustion::Application }
  let(:app_root) { app.root }
  let(:schema) { "#{app_root}/db/schema.rb" }

  around do |example|
    begin
      FileUtils.rm schema if File.exist? schema
      example.run
    ensure
      FileUtils.rm schema if File.exist? schema
    end
  end

  describe 'db:schema:dump' do
    it "dumps the schema in 'db/schema.rb'" do
      Dir.chdir app_root do
        `rake db:schema:dump`
        expect(File.exist?(schema)).to be true
      end
    end

    it 'append the migration schema information if any' do
      Dir.chdir app_root do
        `rake db:migrate db:schema:dump`
        sqls = [
          Sequel::Model.db.from(
            :schema_migrations
          ).insert_sql(:filename => '1273253849_add_twitter_handle_to_users.rb'),
          Sequel::Model.db.from(
            :schema_migrations
          ).insert_sql(:filename => '1365762738_add_display_name_to_users.rb'),
          Sequel::Model.db.from(
            :schema_migrations
          ).insert_sql(:filename => '1365762739_add_github_username_to_users.rb')
        ]
        content = if ENV['TEST_ADAPTER'] == 'postgresql'
                    <<-EOS
                      Sequel.migration do
                        change do
                          self << "SET search_path TO \\"$user\\", public"
                          #{sqls.map { |sql| "self << #{sql.inspect}" }.join("\n")}
                        end
                      end
                    EOS
                  else
                    <<-EOS
                      Sequel.migration do
                        change do
                          #{sqls.map { |sql| "self << #{sql.inspect}" }.join("\n")}
                        end
                      end
                    EOS
                  end.gsub(/^\s+/, '').strip
        expect(File.read(schema).gsub(/^\s+/, '')).to include content
      end
    end
  end

  describe 'db:structure:dump', :skip_jdbc do
    let(:schema) { "#{app_root}/db/structure.sql" }

    it "dumps the schema in 'db/structure.sql'" do
      Dir.chdir app_root do
        `rake db:structure:dump`
        expect(File.exist?(schema)).to be true
      end
    end

    it 'append the migration schema information if any' do
      Dir.chdir app_root do
        `rake db:migrate db:structure:dump`

        sql = Sequel::Model.db.from(
          :schema_migrations
        ).insert_sql(:filename => '1273253849_add_twitter_handle_to_users.rb')
        expect(File.read(schema)).to include sql
      end
    end
  end

  describe 'db:rollback' do
    let(:version) { nil }
    let(:rake_task_call) do
      if version
        proc { `rake db:rollback VERSION=#{version}` }
      else
        proc { `rake db:rollback` }
      end
    end

    it 'revert latest migration' do
      Dir.chdir app_root do
        begin
          expect do
            rake_task_call.call
          end.to change { SequelRails::Migrations.current_migration }.from(
            '1365762739_add_github_username_to_users.rb'
          ).to('1365762738_add_display_name_to_users.rb')
        ensure
          SequelRails::Migrations.migrate_up!
        end
      end
    end

    context 'when version supplied' do
      context 'same as current version' do
        let(:version) { '1365762739' }

        it 'does not revert' do
          Dir.chdir app_root do
            begin
              expect do
                rake_task_call.call
              end.not_to change { SequelRails::Migrations.current_migration }
            ensure
              SequelRails::Migrations.migrate_up!
            end
          end
        end
      end
      context 'same as last version' do
        let(:version) { '1365762738' }

        it 'revert latest migration' do
          Dir.chdir app_root do
            begin
              expect do
                rake_task_call.call
              end.to change { SequelRails::Migrations.current_migration }.from(
                '1365762739_add_github_username_to_users.rb'
              ).to('1365762738_add_display_name_to_users.rb')
            ensure
              SequelRails::Migrations.migrate_up!
            end
          end
        end
      end
      context 'smaller than last version' do
        let(:version) { '1273253849' }

        it 'revert until migration specified by version' do
          Dir.chdir app_root do
            begin
              expect do
                rake_task_call.call
              end.to change { SequelRails::Migrations.current_migration }.from(
                '1365762739_add_github_username_to_users.rb'
              ).to('1273253849_add_twitter_handle_to_users.rb')
            ensure
              SequelRails::Migrations.migrate_up!
            end
          end
        end
      end
    end
  end

  describe 'db:migrate:redo' do
    it 'run down then up of the latest migration' do
      Dir.chdir app_root do
        SequelRails::Migrations.migrate_up!
        expect do
          `rake db:migrate:redo`
        end.not_to change { SequelRails::Migrations.current_migration }
      end
    end
  end

  describe 'db:sessions:clear' do
    let(:sessions) { Sequel::Model.db.from(:sessions) }

    after { sessions.delete }

    it 'truncates sessions table' do
      sessions.insert session_id: 'foo', data: ''
      sessions.insert session_id: 'bar', data: ''

      Dir.chdir app_root do
        expect { `rake db:sessions:clear` }.to change { sessions.count }.by(-2)
      end
    end
  end

  describe 'db:sessions:trim' do
    let(:sessions) { Sequel::Model.db.from(:sessions) }

    before do
      sessions.insert session_id: 'foo', data: '', updated_at: (Date.today - 60).to_time
      sessions.insert session_id: 'bar', data: '', updated_at: Date.today.to_time
    end

    after { sessions.delete }

    it 'delete sessions before cutoff' do
      Dir.chdir app_root do
        expect { `rake db:sessions:trim` }.to change { sessions.count }.by(-1)
      end
    end

    context 'with threshold' do
      it 'delete sessions before cutoff' do
        sessions.insert session_id: 'baz', data: '', updated_at: (Date.today - 44).to_time

        Dir.chdir app_root do
          expect { `rake db:sessions:trim[45]` }.to change { sessions.count }.by(-1)
        end
      end
    end
  end
end
