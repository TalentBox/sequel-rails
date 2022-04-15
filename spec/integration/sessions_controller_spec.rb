require 'spec_helper'

describe SessionsController, :type => :request do
  let(:session_class) { ::ActionDispatch::Session::SequelStore.session_class }

  def login
    opts = if ActionPack::VERSION::MAJOR >= 5
      {params: {:status => 'logged_in'}}
    else
      {:status => 'logged_in'}
    end
    post '/session', **opts
  end

  describe '#create' do
    it 'creates a new session' do
      expect do
        login
      end.to change { session_class.count }.from(0).to(1)
      expect(session[:status]).to eq 'logged_in'
    end
  end

  describe '#destroy' do
    before { login }
    it 'reset session' do
      old_session_id = cookies['_session_id']
      delete '/session'
      expect(old_session_id).not_to eq cookies['_session_id']
      expect(session[:status]).to be_nil
    end
  end
end
