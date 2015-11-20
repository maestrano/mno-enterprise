require 'rails_helper'

module MnoEnterprise
  describe UserSetupController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    
    # Create user and organization + mutual associations
    let(:organization) { build(:organization) }
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { allow(organization).to receive(:users).and_return([user]) }
    before { allow_any_instance_of(User).to receive(:organizations).and_return([organization]) }
    
    
    
    describe 'GET #index' do
      subject { get :index }
      
      describe 'guest' do
        before { subject }
        it { expect(response).to redirect_to(new_user_session_path) }
      end
      
      describe 'signed in' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
      end
    end
    
  end
end