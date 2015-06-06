require 'rails_helper'

module MnoEnterprise
  describe Webhook::OAuthController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    
    # Stub model calls
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:app_instance) { build(:app_instance) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/app_instances", response: from_api([app_instance])) }
    
    describe 'GET #authorize' do
      before { sign_in user }
      subject { get :authorize, id: app_instance.uid }
      
      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"
      
      it { subject; expect(response).to be_success }
    end
    
  end
end