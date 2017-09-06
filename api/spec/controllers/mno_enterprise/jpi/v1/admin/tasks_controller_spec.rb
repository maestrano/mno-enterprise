require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TasksController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
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
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: '/tasks', response: from_api([task]))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization]))
      sign_in user
    end

    #==========================
    # =====================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }
      it_behaves_like "a jpi v1 admin action"
      context 'success' do
        before { subject }
        it 'returns a list of users' do
          expect(response).to be_success
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: task.id }
      before do
        api_stub_for(get: "/tasks/#{task.id}", response: from_api(task))
      end
      it_behaves_like "a jpi v1 admin action"
      context 'success' do
        before { subject }
        it 'returns a complete description of the task' do
          expect(response).to be_success
        end
      end
    end
  end
end
