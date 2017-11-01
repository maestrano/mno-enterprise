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
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation) }
    let!(:current_user_stub) { stub_user(user) }

    before { stub_api_v2(:get, '/orga_relations', orga_relation, [], { filter: { 'user.id': user.id, 'organization.id': organization.id }, page: { number: 1, size: 1 } }) }

    describe 'GET #index' do
      let(:app_instance) { build(:app_instance, status: 'running', under_free_trial: false) }
      let!(:stub) { stub_api_v2(:get, '/app_instances', [app_instance], [:app], { filter: { 'owner.id': organization.id, 'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(','), fulfilled_only: true } }) }
      before { sign_in user }
      subject { get :index, organization_id: organization.id }

      it_behaves_like 'jpi v1 protected action'

      describe 'all' do
        it do
          subject
          expect(subject).to be_successful
          expect(stub).to have_been_requested
        end
      end

      context 'without access to the app_instance' do
        before { allow(ability).to receive(:can?).with(any_args).and_return(false) }
        it do
          subject
          expect(assigns(:app_instances)).to be_empty
        end
      end
    end

    describe 'POST #create' do
      before { stub_audit_events }
      let(:app) { build(:app, nid: 'my-app') }
      let(:app_instance) { build(:app_instance, app: app, owner: organization) }
      subject { post :create, organization_id: organization.id, nid: 'my-app' }
      it_behaves_like 'jpi v1 protected action'
      let!(:stub) { stub_api_v2(:post, '/app_instances/provision', app_instance) }
      before do
        sign_in user
      end

      it do
        expect(subject).to be_successful
        expect(stub).to have_been_requested
      end
    end

    describe 'DELETE #destroy' do
      before { stub_audit_events }
      let(:app_instance) { build(:app_instance, owner: organization) }
      let(:terminated_app_instance) { build(:app_instance, id: app_instance.id, status: 'terminated') }
      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner]) }
      let!(:stub) { stub_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate", terminated_app_instance) }


      before { sign_in user }
      subject { delete :destroy, id: app_instance.id }

      it_behaves_like 'jpi v1 protected action'

      it {
        subject
        expect(stub).to have_been_requested
        expect(assigns(:app_instance).status).to eq('terminated')
      }
    end
  end
end
