require "spec_helper"

describe SequelRails::Storage::Jdbc do
  let(:adapter)             { 'jdbc:mysql' }
  let(:auto_reconnect)      { true }
  let(:connection_handling) { 'queue' }
  let(:database)            { 'test' }
  let(:host)                { 'localhost' }
  let(:password)            { nil }
  let(:pool)                { 80 }
  let(:user)                { 'root' }
  let(:timeout)             { 5000 }
  let(:config) do
    {
      'password' => password,
      'pool' => pool,
      'autoReconnect' => auto_reconnect,
      'adapter' => adapter,
      'timeout' => timeout,
      'connection_handling' => connection_handling,
      'user' => user,
      'host' => host,
      'database' => database,
      'url' => "#{adapter}://#{host}/#{database}?password=#{password}&pool=#{pool}&autoReconnect=#{auto_reconnect}&timeout=#{timeout}&connection_handling=#{connection_handling}&user=#{user}"
    }
  end
  let(:store) { described_class.new(config) }

  describe "#_root_url" do
    subject { store._root_url }
    let(:expected) { "jdbc:mysql://#{host}" }

    it { should == expected }

    context "with ip addresses" do
      let(:host) { '127.0.0.1'}

      it { should == expected }
    end
  end
end
