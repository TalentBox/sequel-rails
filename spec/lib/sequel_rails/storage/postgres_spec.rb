require 'spec_helper'

describe SequelRails::Storage::Postgres, :postgres do
  let(:username)      { 'username' }
  let(:host)          { 'host' }
  let(:port)          { 1234 }
  let(:password)      { 'password' }
  let(:maintenance_db) { 'maintenance_db' }
  let(:encoding)      { 'encoding' }
  let(:locale)        { 'locale' }
  let(:collation)     { 'collation' }
  let(:ctype)         { 'ctype' }
  let(:template)      { 'template' }
  let(:tablespace)    { 'tablespace' }
  let(:owner)         { 'owner' }
  let(:database)      { 'database' }
  let(:config) do
    {
      'adapter' => 'postgres',
      'username' => username,
      'password' => password,
      'host' => host,
      'port' => port,
      'maintenance_db' => maintenance_db,
      'encoding' => encoding,
      'locale' => locale,
      'collation' => collation,
      'ctype' => ctype,
      'template' => template,
      'tablespace' => tablespace,
      'owner' => owner,
      'database' => database,
    }
  end

  subject { described_class.new config }

  describe '#_create' do
    context 'with all possible options' do
      it 'uses the createdb command' do
        expect(subject).to receive(:`).with(
          "createdb --username\\=#{username} --host\\=#{host} --port\\=#{port} --maintenance-db\\=#{maintenance_db} --encoding\\=#{encoding} --locale\\=#{locale} --lc-collate\\=#{collation} --lc-ctype\\=#{ctype} --template\\=#{template} --tablespace\\=#{tablespace} --owner\\=#{owner} #{database}"
        )
        subject._create
      end
    end

    context 'with only a subset of possible options' do
      let(:maintenance_db) { '' }
      let(:locale) { '' }
      it 'uses the createdb command' do
        expect(subject).to receive(:`).with(
          "createdb --username\\=#{username} --host\\=#{host} --port\\=#{port} --encoding\\=#{encoding} --lc-collate\\=#{collation} --lc-ctype\\=#{ctype} --template\\=#{template} --tablespace\\=#{tablespace} --owner\\=#{owner} #{database}"
        )
        subject._create
      end
    end

    it 'sets and remove the password in environment variable PGPASSWORD' do
      expect(ENV['PGPASSWORD']).to be_nil
      expect(subject).to receive(:`) do |_|
        expect(ENV['PGPASSWORD']).to eq(password)
      end
      subject._create
      expect(ENV['PGPASSWORD']).to be_nil
    end
  end

  describe '#_drop' do
    it 'uses the dropdb command' do
      expect(subject).to receive(:`).with(
        "dropdb --username\\=#{username} --host\\=#{host} --port\\=#{port} --if-exists #{database}"
      )
      subject._drop
    end
    it 'sets and remove the password in environment variable PGPASSWORD' do
      expect(ENV['PGPASSWORD']).to be_nil
      expect(subject).to receive(:`) do |_|
        expect(ENV['PGPASSWORD']).to eq(password)
      end
      subject._drop
      expect(ENV['PGPASSWORD']).to be_nil
    end
  end

  describe '#drop' do
    before do
      stub_const('Sequel::DATABASES', [])
    end

    it 'properly executes without active sequel connections' do
      expect(Sequel::Model).not_to receive(:db)
      subject.drop
    end
  end

  describe '#_dump' do
    let(:dump_file_name) { 'dump.sql' }
    it 'uses the pg_dump command' do
      expect(subject).to receive(:`).with(
        "pg_dump --username\\=#{username} --host\\=#{host} --port\\=#{port} -s -x -O --file\\=#{dump_file_name} #{database}"
      )
      subject._dump dump_file_name
    end
    it 'sets and remove the password in environment variable PGPASSWORD' do
      expect(ENV['PGPASSWORD']).to be_nil
      expect(subject).to receive(:`) do |_|
        expect(ENV['PGPASSWORD']).to eq(password)
      end
      subject._dump dump_file_name
      expect(ENV['PGPASSWORD']).to be_nil
    end
  end

  describe '#_load' do
    let(:dump_file_name) { 'dump.sql' }
    it 'uses the psql command' do
      expect(subject).to receive(:`).with(
        "psql --username\\=#{username} --host\\=#{host} --port\\=#{port} --file\\=#{dump_file_name} #{database}"
      )
      subject._load dump_file_name
    end
    it 'sets and remove the password in environment variable PGPASSWORD' do
      expect(ENV['PGPASSWORD']).to be_nil
      expect(subject).to receive(:`) do |_|
        expect(ENV['PGPASSWORD']).to eq(password)
      end
      subject._load dump_file_name
      expect(ENV['PGPASSWORD']).to be_nil
    end
  end
end
