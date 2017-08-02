require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppQuestionsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation, user: user, organization: organization) }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    before { sign_in user }

    let(:app) { build(:app) }

    let(:question_id) { "1" }
    let(:question_answer1) { build(:answer, parent_id: question_id) }
    let(:question_answer2) { build(:answer, parent_id: question_id) }
    let(:rejected_answer) { build(:answer, parent_id: question_id, status: 'rejected') }
    let(:question) { build(:question, id: question_id, answers: [question_answer1, question_answer2, rejected_answer]) }

    before do
      stub_api_v2(:get, "/apps/#{app.id}", app)
    end

    describe 'GET #index' do

      before do
        stub_api_v2(:get, '/questions', [question], [:answers], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App', status: 'approved', reviewable_id: app.id}})
      end

      subject { get :index, id: app.id }

      it_behaves_like 'jpi v1 protected action'

      it_behaves_like 'a paginated action'

      it 'renders the list of reviews' do
        subject
        expected = hash_for_question(question)
        # Only approved answers
        expected['answers'] = [hash_for_answer(question_answer1), hash_for_answer(question_answer2)]
        expect(JSON.parse(response.body)['app_questions'][0]).to eq(expected)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: organization.id, description: 'A Review', foo: 'bar'} }
      let(:question) { build(:question, id: question_id, answers: []) }
      before do
        stub_api_v2(:get, '/orga_relations', [orga_relation], [], {filter: {organization_id: organization.id, user_id: user.id}, page: {number: 1, size: 1}})
        stub_api_v2(:post, '/questions', question)
      end
      subject { post :create, id: app.id, app_question: params }

      it_behaves_like 'jpi v1 protected action'

      it 'renders the new review' do
        expect(JSON.parse(subject.body)['app_question']).to include(hash_for_question(question))
      end
    end
  end
end
