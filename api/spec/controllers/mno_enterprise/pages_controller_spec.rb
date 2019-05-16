require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Freeze time (JWT are time dependent)
    before { Timecop.freeze }
    after { Timecop.return }

    before { stub_audit_events }

    let(:user) { build(:user) }
    let(:app_instance) { build(:app_instance) }

    before do
      stub_user(user)
      stub_api_v2(:get, '/app_instances', [app_instance], [], {filter:{uid: app_instance.uid}, page:{number: 1, size: 1}})
    end

    describe 'GET #launch' do
      before { sign_in user }
      subject { get :launch, id: app_instance.uid }

      it_behaves_like "a navigatable protected user action"

      it 'redirect to the mno enterprise launch page with a web token' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid, wtk: MnoEnterprise.jwt({user_id: user.uid})))
      end
    end

    describe 'GET #launch with parameters' do
      let(:app_instance) { build(:app_instance) }
      before { sign_in user }
      subject { get :launch, id: app_instance.uid, specific_parameters: 'specific_parameters_value' }

      it_behaves_like "a navigatable protected user action"

      it 'redirects to the mno enterprise launch page with a web token and extra params' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid, wtk: MnoEnterprise.jwt({user_id: user.uid}), specific_parameters: 'specific_parameters_value'))
      end
    end

    describe 'GET #deeplink with parameters' do
      let(:organization) { build(:organization) }
      let(:entity_type) { 'invoices' }
      let(:entity_id) { SecureRandom.uuid }
      before { sign_in user }
      subject { get :deeplink, organization_id: organization.uid, entity_type: entity_type, entity_id: entity_id, specific_parameters: 'specific:parameters_value' }

      it_behaves_like "a navigatable protected user action"

      it 'redirects to the mno enterprise deeplink page with a web token and extra params' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.deeplink_url(organization.uid, entity_type, entity_id, wtk: MnoEnterprise.jwt({user_id: user.uid}), specific_parameters: 'specific:parameters_value'))
      end
    end

    describe 'GET #loading' do
      subject { get :loading, id: app_instance.uid }

      before do
        stub_api_v2(:get, '/app_instances', [app_instance], [:app], {filter: {uid: app_instance.uid}, page: {number: 1, size: 1}})
      end

      it { is_expected.to be_success }

      context 'JSON format' do
        before { request.env['HTTP_ACCEPT'] = 'application/json' }

        it 'returns the application hash' do
          Timecop.freeze do
            expected_hash = {
              'id' => app_instance.id,
              'uid' => app_instance.uid,
              'name' => 'SomeApp',
              'status' => 'running',
              'durations' => app_instance.durations,
              'started_at' => app_instance.started_at.to_s(:iso8601),
              'stopped_at' => nil,
              'created_at' => app_instance.created_at.to_s(:iso8601),
              'server_time' => Time.now.utc.to_s(:iso8601),
              'is_online' => true,
              'errors' => [],
              'logo' => app_instance.app.logo
            }
            expect(JSON.parse(subject.body)).to eq(expected_hash)
          end
        end

        context 'when the application is not found' do
          before do
            stub_api_v2(:get, '/app_instances', [], [:app], {filter: {uid: app_instance.uid}, page: {number: 1, size: 1}})
          end

          it { expect(JSON.parse(subject.body)).to eq({}) }
        end
      end
    end

    describe 'GET #app_access_unauthorized' do
      subject { get :app_access_unauthorized }
      before { subject }
      it { expect(response).to be_success }
    end

    describe 'GET #billing_details_required' do
      subject { get :billing_details_required }
      before { subject }
      it { expect(response).to be_success }
    end

    describe 'GET #app_logout' do
      subject { get :app_logout }
      before { subject }
      it { expect(response).to be_success }
    end

    describe 'GET #terms' do
      let(:app1) { build(:app, name: 'b', terms_url: nil) }
      let(:app2) { build(:app, name: 'a') }
      let(:app3) { build(:app, name: 'c') }

      before do
        Rails.cache.clear
        stub_api_v2(:get, '/apps', [app1], [], {fields: {apps: 'updated_at'}, page: {number: 1, size: 1}, sort: '-updated_at'})
        stub_api_v2(:get, '/apps', [app1, app2, app3], [], {fields: {apps: [:name, :terms_url].join(',')}, sort: 'name'})
      end

      subject { get :terms }
      before { subject }

      it { expect(response).to be_success }

      it 'rejects the apps with not terms_url' do
        expect(assigns(:apps).map(&:id)).to include(app2.id, app3.id)
      end
    end
  end
end
