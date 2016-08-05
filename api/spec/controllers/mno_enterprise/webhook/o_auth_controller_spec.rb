require 'rails_helper'

def main_app
  Rails.application.class.routes.url_helpers
end

module MnoEnterprise
  describe Webhook::OAuthController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub controller ability
    let!(:ability) { stub_ability }
    let(:extra_params) { {some: 'param'} }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/app_instances", response: from_api([app_instance])) }
    before { allow_any_instance_of(MnoEnterprise::AppInstance).to receive(:app).and_return(app) }

    describe 'GET #authorize' do
      let(:redir_params) { extra_params.reject { |k, v| k.to_sym == :perform } }
      let(:redirect_url) { MnoEnterprise.router.authorize_oauth_url(app_instance.uid, redir_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      subject { get :authorize, extra_params.merge(id: app_instance.uid) }
      before { sign_in user }

      it_behaves_like 'a navigatable protected user action'
      it_behaves_like 'a user protected resource'

      it { subject; expect(response).to be_success }
      it { Timecop.freeze { subject; expect(assigns(:redirect_to)).to eq(redirect_url) } }

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

        let(:fragment) { "#?#{URI.encode_www_form([['flash', {msg: 'We could not validate your credentials, please try again', type: :error}.to_json]])}" }

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
    end

    describe 'GET #sync' do
      let(:redirect_url) { MnoEnterprise.router.sync_oauth_url(app_instance.uid, extra_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      before { sign_in user }
      subject { get :sync, extra_params.merge(id: app_instance.uid) }

      it_behaves_like 'a navigatable protected user action'
      it_behaves_like 'a user protected resource'

      it { subject; expect(response).to redirect_to(redirect_url) }
    end
  end
end
