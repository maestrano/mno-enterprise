require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  describe Jpi::V1::AppInstancesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    # Stub organization + associations
    let(:organization) { build(:organization) }
    before { allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) }

    describe 'GET #index' do
      let(:app_instance) { build(:app_instance, status: "running") }
      let(:app_instances) { instance_double('Her::Model::Relation') }

      before do
        allow(organization).to receive(:app_instances).and_return(app_instances)
        # Only active instances
        allow(app_instances).to receive(:active).and_return(app_instances)
        # Updated since last tick
        allow(app_instances).to receive(:where).and_return([app_instance])
      end

      before { sign_in user }
      let(:timestamp) { nil }
      subject { get :index, organization_id: organization.id, timestamp: timestamp }

      it_behaves_like "jpi v1 protected action"

      describe 'all' do
        it { subject; expect(assigns(:app_instances)).to eq([app_instance]) }

        it 'filter only active instances' do
          expect(app_instances).to receive(:active)
          subject
        end
      end

      context 'with timestamp' do
        let(:timestamp) { Time.current.to_i }

        it 'filter updates since last request' do
          expect(app_instances).to receive(:where).with("updated_at.gt" => Time.at(timestamp))
          subject
        end
      end

      context 'without access to the app_instance' do
        before { allow(ability).to receive(:can?).with(any_args).and_return(false) }
        before { subject }
        it { expect(assigns(:app_instances)).to be_empty }
      end
    end

    describe 'POST #create' do
      subject { post :create, organization_id: organization.id, nid: 'my-app' }

      before do
        api_stub_for(post: "/organizations/#{organization.id}/app_instances")
        api_stub_for(get: "/organizations/#{organization.id}/app_instances")
      end


      it_behaves_like "jpi v1 protected action"
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
