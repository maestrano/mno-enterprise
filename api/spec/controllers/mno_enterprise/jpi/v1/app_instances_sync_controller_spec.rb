require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppInstancesSyncController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    # include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }

    # Stub organization
    # Stub organization and association
    let!(:organization) {
      o = build(:organization, orga_relations: [])
      o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: 'Super Admin')
      o
    }
    before { stub_api_v2(:get, '/organizations', [organization], %i(orga_relations users), {filter: {uid: organization.uid}}) }

    # Apps sync
    let(:connectors) { [
      HashWithIndifferentAccess.new(name: 'a_name', status: 'RUNNING', date: nil),
      HashWithIndifferentAccess.new(name: 'a_name', status: 'FAILED', date: nil)
    ] }

    let!(:organization_with_connectors) { build(:organization, connectors: connectors, has_running_cube: false) }

    #===============================================
    # Specs
    #===============================================
    describe 'GET #index' do
      before { stub_api_v2(:get, "/organizations/#{organization.id}/app_instances_sync", [organization_with_connectors]) }

      subject { get :index, organization_id: organization.uid }

      it_behaves_like 'jpi v1 protected action'

      it 'returns the fetched connectors' do
        subject
        expect(JSON.parse(response.body)['connectors']).to eq(connectors)
      end

      context 'without cubes' do
        before { subject }
        it { expect(JSON.parse(response.body)['has_running_cube']).to be_falsey }
      end

      context 'without cubes' do
        let!(:organization_with_cubes) { build(:organization, connectors: connectors, has_running_cube: true) }
        before {
          stub_api_v2(:get, "/organizations/#{organization.id}/app_instances_sync", [organization_with_cubes])
          subject
        }
        it { expect(JSON.parse(response.body)['has_running_cube']).to be_truthy }
      end

      context 'when a connector is still syncing' do
        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_truthy }
      end

      context 'when no connector is syncing' do
        let(:connectors) { [
          HashWithIndifferentAccess.new({name: 'a_name', status: 'FAILED', date: nil})
        ] }

        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_falsey }
      end

      context 'when connector is pending' do
        let(:connectors) { [
          HashWithIndifferentAccess.new({name: 'a_name', status: 'PENDING', date: nil})
        ] }
        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_truthy }
      end
    end

    describe 'POST #create' do
      # Apps sync
      let(:sync_results) { {connectors: []} }

      before { stub_api_v2(:post, "/organizations/#{organization.id}/trigger_app_instances_sync", [organization_with_connectors]) }

      subject { post :create, organization_id: organization.uid, mode: 'a_mode', return_url: 'a/random/url' }
      before { subject }
      it 'calls trigger_app_instances_sync api' do
        assert_requested_api_v2(:post, "/organizations/#{organization.id}/trigger_app_instances_sync", times: 1)
      end
      it 'returns the fetched connectors' do
        expect(JSON.parse(response.body)['connectors']).to eq(connectors)
      end
    end
  end
end
