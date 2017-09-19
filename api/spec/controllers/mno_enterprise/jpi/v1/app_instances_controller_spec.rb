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

      before { stub_api_v2(:get, '/app_instances', [app_instance], [:app], {extra_fields: true, filter: {owner_id: organization.id, 'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')}}) }

      before { sign_in user }
      subject { get :index, organization_id: organization.id }

      it_behaves_like 'jpi v1 protected action'

      describe 'all' do
        it {
          subject
          # TODO: Test that the rendered json is the expected one
          # expect(assigns(:app_instances)).to eq([app_instance])
          assert_requested(:get, api_v2_url('/app_instances', [:app], {extra_fields:true, _locale: I18n.locale, filter: {owner_id: organization.id, 'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')}}))
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
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance)}
      before { stub_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate", terminated_app_instance)}
      before { stub_api_v2(:get, "/organizations/#{app_instance.owner_id}")}
      before { sign_in user }
      subject { delete :destroy, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        assert_requested_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate")
        expect(assigns(:app_instance).status).to eq('terminated')
      }
    end
  end
end
