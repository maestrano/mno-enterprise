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
      let(:progress_results) { { connectors: [], errors: [] } }
      before { api_stub_for(get: "/organizations/#{organization.id}/app_instances_sync/anything", response: from_api(progress_results)) }

      subject { get :index, organization_id: organization.uid }
      
      it_behaves_like "jpi v1 protected action"

      it "verifies the user's rights" do
        expect(ability).to receive(:can?).with(:check_apps_sync, organization)
        subject
      end

      context "when a connector is still syncing" do
        let(:progress_results) { { connectors: [{status: 'RUNNING'}], errors: [] } }
        before { subject }
        it { expect(JSON.parse(response.body)).to include({'syncing' => true}) }
      end

      context "when the connectors are synced" do
        let(:c1) { HashWithIndifferentAccess.new({last_synced: (DateTime.now - 2.minutes).to_json}) }
        let(:c2) { HashWithIndifferentAccess.new({last_synced: (DateTime.now).to_json}) }
        let(:progress_results) { { connectors: [c1, c2], errors: [] } }

        before { subject }

        it "sorts the connectors by reverted sync_date" do
          expect(JSON.parse(response.body)).to include({'connectors' => [c2,c1]})
        end

        it "finds the last synced connector" do
          expect(JSON.parse(response.body)).to include({'last_synced' => c2})
        end
      end

      context "when there are some errors" do
        let(:err) { HashWithIndifferentAccess.new({an: 'error'}) }
        let(:progress_results) { { connectors: [], errors: [err] } }
        
        before { subject }

        it "includes then in the response" do
          expect(JSON.parse(response.body)).to include({'errors' => [err]})
        end
      end
    end

    describe "POST #create" do
      xit "to spec: cannot stub 'post /app_instances_syncs data%5Bmode%5D=a_mode'"

      # # Apps sync
      # let(:sync_results) { [] }
      # before { api_stub_for(post: "/app_instances_sync", response: from_api(sync_results)) }

      # subject { post :create, organization_id: organization.uid, mode: 'a_mode', return_url: 'a/random/url' }

      # it "verifies the user's rights" do
      #   expect(ability).to receive(:can?).with(:sync_apps, organization)
      #   subject
      # end

      # it "stores the return url into the session" do
      #   subject
      #   expect(controller.session).to include({pre_sync_url: 'a/random/url'})
      # end

      # context "when the sync returns no result" do
      #   before { subject }
      #   it { expect(JSON.parse(response.body)).to eq({'msg' => "No apps available for synchronization! Please either add applications to your dashboard or check they're authenticated."}) }
      # end

      # context "when the sync returns at least one false result" do
      #   let(:sync_results) { [true, 'something', false] }
      #   before { subject }
      #   it { expect(JSON.parse(response.body)).to eq({'msg' => "We were unable to sync your data. Please retry at a later time."}) }
      # end

      # context "when the sync returns successful results" do
      #   let(:sync_results) { [true, 'someting', {hash: 'result'}] }
      #   before { subject }
      #   it { expect(JSON.parse(response.body)).to eq({'msg' => "Syncing your data. This process might take a few minutes."}) }
      # end
    end
  end
end
