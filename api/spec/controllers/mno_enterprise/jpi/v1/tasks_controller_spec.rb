require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::TasksController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, :admin, organizations: [organization]) }
    let(:organization) { build(:organization) }
    let(:task) { build(:task, task_recipients: [build(:task_recipient)]) }
    let(:orga_relation) { build(:orga_relation) }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: '/tasks', response: from_api([task]))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization]))
      api_stub_for(get: "/orga_relations?filter%5Borganization_id%5D=#{organization.id}&filter%5Buser_id%5D=#{user.id}", response: from_api([orga_relation]))
      sign_in user
    end

    #===============================================
    # Specs
    #===============================================
    describe 'GET #index' do
      subject { get :index, organization_id: organization.id }
      context 'success' do
        before { subject }
        it 'returns a list of users' do
          expect(response).to be_success
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: task.id, organization_id: organization.id }
      before do
        api_stub_for(get: "/tasks/#{task.id}", response: from_api(task))
      end
      context 'success' do
        before { subject }
        it 'returns a complete description of the task' do
          expect(response).to be_success
        end
      end
    end
  end
end
