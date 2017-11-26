require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  describe Jpi::V1::AppInstancesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    # Stub ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }

    # Stub organization and association
    let!(:organization) {
      o = build(:organization, orga_relations: [])
      o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: 'Super Admin')
      o
    }
    before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }

    describe 'GET #index' do

      let(:app_instance) { build(:app_instance, status: 'running' , under_free_trial: false) }

      before { stub_api_v2(:get, '/app_instances', [app_instance], [:app], {fields: {app_instances: MnoEnterprise::AppInstance::REQUIRED_INDEX_FIELDS.join(',')}, filter: {owner_id: organization.id, 'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(','), 'fulfilled_only': true }}) }

      before { sign_in user }
      subject { get :index, organization_id: organization.id }

      it_behaves_like 'jpi v1 protected action'

      describe 'all' do
        it {
          subject
          # TODO: Test that the rendered json is the expected one
          # expect(assigns(:app_instances)).to eq([app_instance])
          assert_requested(:get, api_v2_url('/app_instances', [:app], {fields: {app_instances: MnoEnterprise::AppInstance::REQUIRED_INDEX_FIELDS.join(',')}, _locale: I18n.locale, filter: {owner_id: organization.id, 'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(','), 'fulfilled_only': true }}))
        }
      end

      context 'without access to the app_instance' do
        before { allow(ability).to receive(:can?).with(any_args).and_return(false) }
        it {
          subject
          expect(assigns(:app_instances)).to be_empty
        }
      end
    end

    describe 'POST #create' do
      before { stub_audit_events }
      let(:app) { build(:app, nid: 'my-app') }
      let(:app_instance) { build(:app_instance, app: app, owner: organization, owner_id: organization.id) }
      subject { post :create, organization_id: organization.id, nid: 'my-app' }
      it_behaves_like 'jpi v1 protected action'
      before do
        stub_api_v2(:post, '/app_instances/provision', app_instance)
        sign_in user
      end

      it {
        expect(subject).to be_successful
        assert_requested_api_v2(:post, '/app_instances/provision')
      }
    end

    describe 'DELETE #destroy' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance) }
      let(:terminated_app_instance) { build(:app_instance, id: app_instance.id, status: 'terminated') }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner]) }
      before { stub_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate", terminated_app_instance) }
      before { sign_in user }
      subject { delete :destroy, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        assert_requested_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate")
        expect(assigns(:app_instance).status).to eq('terminated')
      }
    end

    describe 'GET #setup_form' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance, metadata: { app: { host: 'http://www.addon-url.com'} }) }
      let(:form) { { form: {} } }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:app, :owner])}
      before { stub_add_on(app_instance, :get, '/maestrano/api/account/setup_form', 200, form) }
      before { sign_in user }
      subject { get :setup_form, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        expect(JSON.parse(response.body)).to eq(form.with_indifferent_access)
      }
    end

    describe 'POST #create_omniauth' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance, metadata: { app: { host: 'http://www.addon-url.com' } }) }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:app, :owner])}
      before { stub_add_on(app_instance, :post, "/maestrano/api/account/link_account", 202) }
      before { sign_in user }
      subject { post :create_omniauth, id: app_instance.id, app_instance: {} }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        expect(subject).to be_successful
      }
    end

    describe 'POST #sync' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance, metadata: { app: { host: 'http://www.addon-url.com', synchronization_start_path: '/sync' } }) }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:app, :owner])}
      before { stub_add_on(app_instance, :post, '/sync', 202) }
      before { sign_in user }
      subject { post :sync, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        expect(subject).to be_successful
      }
    end

    describe 'POST #disconnect' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance, metadata: { app: { host: 'http://www.addon-url.com' } }) }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:app, :owner])}
      before { stub_add_on(app_instance, :post, '/maestrano/api/account/unlink_account', 202) }
      before { sign_in user }
      subject { post :disconnect, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        expect(subject).to be_successful
      }
    end

    describe 'GET #sync_history' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance) }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner])}
      let(:sync) {
        {
          status: "SUCCESS",
          message: nil,
          updated_at: "2017-10-03T23:16:25Z",
          created_at:"2017-10-03T23:16:08Z"
        }
      }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}/sync_history", sync) }
      before { sign_in user }
      subject { get :sync_history, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        assert_requested_api_v2(:get, "/app_instances/#{app_instance.id}/sync_history")
        expect(JSON.parse(response.body).first['attributes']).to eq(sync.with_indifferent_access)
      }
    end

    describe 'GET #id_maps' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance) }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner]) }
      let(:id_map) {
        {
          connec_id: "8d8781c0-94b7-0135-43e8-245e60e5955b",
          external_entity: "product",
          external_id: '1',
          name: "Product1",
          message: "An error ocurred"
        }
      }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}/id_maps", id_map) }
      before { sign_in user }
      subject { get :id_maps, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        assert_requested_api_v2(:get, "/app_instances/#{app_instance.id}/id_maps")
        expect(JSON.parse(response.body).first['attributes']).to eq(id_map.with_indifferent_access)
      }
    end
  end
end
