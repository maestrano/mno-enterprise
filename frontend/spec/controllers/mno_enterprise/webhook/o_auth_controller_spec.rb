require 'rails_helper'

# Test here in addition to mnoe-api to see that it's working properly with myspace_url
module MnoEnterprise
  describe Webhook::OAuthController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Freeze time (JWT are time dependent)
    before { Timecop.freeze }
    after { Timecop.return }

    # Stub controller ability
    let!(:ability) { stub_ability }
    let(:extra_params) { {some: 'param'} }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, app:app) }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    before do
      stub_api_v2(:get, '/app_instances', [app_instance], %i(owner app), {filter: {uid: app_instance.uid}, page: {number: 1, size: 1}})
    end


    describe 'GET #authorize' do
      let(:redir_params) { extra_params.reject { |k, v| k.to_sym == :perform } }
      let(:redirect_url) { MnoEnterprise.router.authorize_oauth_url(app_instance.uid, redir_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      subject { get :authorize, extra_params.merge(id: app_instance.uid) }
      before { sign_in user }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to be_success }
      it { subject; expect(assigns(:redirect_to)).to eq(redirect_url) }

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

      it { subject; expect(response).to redirect_to(MnoEnterprise.router.dashboard_path) }
    end

    describe 'GET #disconnect' do
      let(:redirect_url) { MnoEnterprise.router.disconnect_oauth_url(app_instance.uid, extra_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      subject { get :disconnect, extra_params.merge(id: app_instance.uid) }
      before { sign_in user }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to redirect_to(redirect_url) }
    end

    describe 'GET #sync' do
      let(:redirect_url) { MnoEnterprise.router.sync_oauth_url(app_instance.uid, extra_params.merge(wtk: MnoEnterprise.jwt(user_id: user.uid))) }
      before { sign_in user }
      subject { get :sync, extra_params.merge(id: app_instance.uid) }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to redirect_to(redirect_url) }
    end
  end
end
