require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppQuestionsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    QUESTION_ATTRIBUTE = %w(id description status app_id app_name user_id user_name organization_id organization_name)

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation, user: user, organization: organization) }
    let!(:current_user_stub) { stub_user(user) }
    let(:app) { build(:app) }
    let(:question_id) { '1' }
    let(:question_answer1) { build(:answer, parent_id: question_id) }
    let(:question_answer2) { build(:answer, parent_id: question_id) }
    let(:question) { build(:question, id: question_id, answers: [question_answer1, question_answer2]) }

    let(:question_hash) {
      hash = hash_for_question(question, QUESTION_ATTRIBUTE)
      hash[:answers].each { |c| c[:type] = 'Answer' }
      hash[:type] = 'Question'
      hash
    }

    before do
      sign_in user
      stub_api_v2(:get, '/questions', [question], [:answers], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App'}})
    end

    describe '#index' do
      subject { get :index }
      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like "an unauthorized route for support users"
      context 'success' do
        before { subject }
        it 'returns a list of app_questions' do
          expect(response).to be_success
          expect(JSON.parse(response.body)['app_questions'][0]).to eq(question_hash)
        end
      end
    end
  end
end
