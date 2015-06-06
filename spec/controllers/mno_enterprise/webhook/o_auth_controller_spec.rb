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
      let(:redirect_url) { MnoEnterprise.router.authorize_oauth_url(app_instance.uid, wtk: MnoEnterprise.jwt(user_id: user.uid)) }
      before { sign_in user }
      subject { get :authorize, id: app_instance.uid }
      
      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"
      
      it { subject; expect(response).to be_success }
      it { subject; expect(assigns(:redirect_to)).to eq(redirect_url)}
    end
    
    describe 'GET #callback' do
      subject { get :callback, id: app_instance.uid }
      
      it { subject; expect(response).to redirect_to(myspace_path) }
    end
    
    describe 'GET #disconnect' do
      let(:redirect_url) { MnoEnterprise.router.disconnect_oauth_url(app_instance.uid, wtk: MnoEnterprise.jwt(user_id: user.uid)) }
      before { sign_in user }
      subject { get :disconnect, id: app_instance.uid }
      
      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"
      
      it { subject; expect(response).to redirect_to(redirect_url) }
    end
    
    describe 'GET #sync' do
      let(:redirect_url) { MnoEnterprise.router.sync_oauth_url(app_instance.uid, wtk: MnoEnterprise.jwt(user_id: user.uid)) }
      before { sign_in user }
      subject { get :sync, id: app_instance.uid }
      
      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"
      
      it { subject; expect(response).to redirect_to(redirect_url) }
    end
  end
end