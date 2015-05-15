require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  describe Jpi::V1::AppInstancesController, type: :controller do
    include JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    
    # Stub ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    
    # Stub user and user call
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    
    # Stub organization/app_instance + associations
    let(:organization) { build(:organization) }
    let(:app_instance) { build(:app_instance, status: "running") }
    before { allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) }
    before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
  
    describe 'GET #index' do
      before { sign_in user }
      let(:timestamp) { nil }
      subject { get :index, organization_id: organization.id, timestamp: timestamp }
    
      it_behaves_like "jpi v1 protected action"
    
      describe 'all' do
        before { subject }
        it { expect(assigns(:app_instances)).to eq([app_instance]) }
      end
    
      describe 'with inactive app_instances' do
        let(:app_instance) { build(:app_instance, status: "terminated", terminated_at: 10.minutes.ago) }
        before { subject }
        it { expect(assigns(:app_instances)).to be_empty }
      end
    
      describe 'with timestamp' do
        describe 'before instance updated_at' do
          let(:timestamp) { (app_instance.updated_at - 2.minutes).to_i }
          before { subject }
          it { expect(assigns(:app_instances)).to eq([app_instance]) }
        end
      
        describe 'after instance updated_at' do
          let(:timestamp) { (app_instance.updated_at + 2.minutes).to_i }
          before { subject }
          it { expect(assigns(:app_instances)).to be_empty }
        end
      end
    end
    
    describe 'DELETE #destroy' do
      let(:app_instance) { build(:app_instance) }
      before { api_stub_for(get: "/app_instances/#{app_instance.id}", respond_with: app_instance)}
      before { api_stub_for(delete: "/app_instances/#{app_instance.id}", response: ->{ app_instance.status = 'terminated'; from_api(app_instance) }) }
      before { sign_in user }
      subject { delete :destroy, id: app_instance.id }
    
      it_behaves_like "jpi v1 protected action"
      
      it { subject; expect(app_instance.status).to eq('terminated')}
    end
  end
end