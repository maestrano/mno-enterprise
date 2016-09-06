require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppInstancesSyncController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    # include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }


    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
    end
    before { sign_in user }

    # Stub organization
    let(:organization) { build(:organization) }
    before { allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) }


    #===============================================
    # Specs
    #===============================================
    describe 'GET #index' do
      # App instances
      let(:app1) { build(:app_instance, owner: organization, status: 'running') }
      let(:app2) { build(:app_instance, owner: organization, status: 'running') }
      before { api_stub_for(put: "/app_instances/#{app1.id}", response: from_api(app1)) }
      before { api_stub_for(put: "/app_instances/#{app2.id}", response: from_api(app2)) }
      before { app1.save ; app2.save }

      # Apps sync
      let(:progress_results) { { connectors: [
        HashWithIndifferentAccess.new({name: 'a_name', status: 'RUNNING', date: nil}),
        HashWithIndifferentAccess.new({name: 'a_name', status: 'FAILED', date: nil})
      ] } }
      before { api_stub_for(get: "/organizations/#{organization.id}/app_instances_sync/anything", response: from_api(progress_results)) }

      subject { get :index, organization_id: organization.uid }

      it_behaves_like "jpi v1 protected action"

      it "verifies the user's rights" do
        expect(ability).to receive(:can?).with(:check_apps_sync, organization)
        subject
      end

      it "returns the fetched connectors" do
        subject
        expect(JSON.parse(response.body)['connectors']).to eq(progress_results[:connectors])
      end

      context "when a connector is still syncing" do
        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_truthy }
      end

      context "when no connector is syncing" do
        let(:progress_results) { { connectors: [
          HashWithIndifferentAccess.new({name: 'a_name', status: 'FAILED', date: nil})
        ] } }
        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_falsey }
      end

      context "when connector is pending" do
        let(:progress_results) { { connectors: [
          HashWithIndifferentAccess.new({name: 'a_name', status: 'PENDING', date: nil})
        ] } }
        before { subject }
        it { expect(JSON.parse(response.body)['is_syncing']).to be_truthy }
      end
    end

    describe "POST #create" do
      it "to spec: cannot stub 'post /app_instances_syncs data%5Bmode%5D=a_mode'"

      # Apps sync
      let(:sync_results) { {connectors: []} }
      before { api_stub_for(post: "/app_instances_syncs", response: from_api(sync_results)) }

      subject { post :create, organization_id: organization.uid, mode: 'a_mode', return_url: 'a/random/url' }

      it "verifies the user's rights" do
        expect(ability).to receive(:can?).with(:sync_apps, organization)
        subject
      end
    end
  end
end
