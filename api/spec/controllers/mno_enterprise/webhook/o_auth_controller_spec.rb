require 'rails_helper'

def main_app
  Rails.application.class.routes.url_helpers
end

module MnoEnterprise
  describe Webhook::OAuthController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Freeze time (JWT are time dependent)
    before { Timecop.freeze }
    after { Timecop.return }

    # Stub controller ability
    let!(:ability) { stub_ability }
    let(:extra_params) { { some: 'param', redirect_path: '/some/path' } }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:user) { build(:user) }
    let!(:organization) {
      o = build(:organization, orga_relations: [])
      o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: 'Super Admin')
      o
    }
    before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }

    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, app: app, owner_id: organization.id) }
    let!(:current_user_stub) { stub_user(user) }

    before do
      stub_api_v2(:get, '/app_instances', [app_instance], %i(app), {filter:{uid: app_instance.uid}, page:{number: 1, size: 1}})
      stub_api_v2(:get, "/organizations/#{organization.id}", organization)
    end

    describe 'GET #authorize' do
      let(:redir_params) { extra_params.reject { |k, v| k.to_sym == :perform } }
      let(:redirect_url) { MnoEnterprise.router.authorize_oauth_url(app_instance.uid, redir_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      subject { get :authorize, extra_params.merge(id: app_instance.uid) }
      before { sign_in user }

      it_behaves_like 'a navigatable protected user action'
      it_behaves_like 'a user protected resource'

      it { subject; expect(response).to be_success }
      it { subject; expect(assigns(:redirect_to)).to eq(redirect_url) }
      it { subject; expect(session[:redirect_path]).to eq(extra_params[:redirect_path]) }

      context 'when connection speedbump is deactivated' do
        before { allow(Settings.dashboard.marketplace).to receive(:connection_speedbump).and_return(false) }
        it { subject; expect(response).to redirect_to(redirect_url) }
      end

      Webhook::OAuthController::PROVIDERS_WITH_OPTIONS.each do |provider|
        describe "#{provider.capitalize} provider" do
          let(:app) { build(:app, nid: provider.parameterize) }
          it { subject; expect(response).to render_template("providers/#{provider.parameterize}") }

          context 'with perform=true' do
            let(:extra_params) { {perform: true} }
            it { subject; expect(assigns(:redirect_to)).to eq(redirect_url) }
          end
        end
      end
    end

    describe 'GET #callback' do
      subject { get :callback, id: app_instance.uid }

      context 'when session has redirect_path' do
        before { session[:redirect_path] = 'http://www.example.com/redirect' }

        it { subject; expect(response).to redirect_to('http://www.example.com/redirect') }
      end

      context 'when there is on oauth error' do
        subject { get :callback, id: app_instance.uid, oauth: {error: :unauthorized} }

        let(:fragment) { "#!?#{URI.encode_www_form([['flash', {msg: 'We could not validate your credentials, please try again', type: :error}.to_json]])}" }

        it { subject; expect(response).to redirect_to(MnoEnterprise.router.dashboard_path + fragment) }
      end

      it { subject; expect(response).to redirect_to(MnoEnterprise.router.dashboard_path) }
    end

    describe 'GET #disconnect' do
      let(:redirect_url) { MnoEnterprise.router.disconnect_oauth_url(app_instance.uid, extra_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      subject { get :disconnect, extra_params.merge(id: app_instance.uid) }
      before { sign_in user }

      it_behaves_like 'a navigatable protected user action'
      it_behaves_like 'a user protected resource'

      it { subject; expect(response).to redirect_to redirect_url }
      it { subject; expect(session[:redirect_path]).to eq(extra_params[:redirect_path]) }
    end

    describe 'GET #sync' do
      let(:redirect_url) { MnoEnterprise.router.sync_oauth_url(app_instance.uid, extra_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      before { sign_in user }
      subject { get :sync, extra_params.merge(id: app_instance.uid) }

      it_behaves_like 'a navigatable protected user action'
      it_behaves_like 'a user protected resource'

      it { subject; expect(response).to redirect_to(redirect_url) }
      it { subject; expect(session[:redirect_path]).to eq(extra_params[:redirect_path]) }
    end
  end
end
