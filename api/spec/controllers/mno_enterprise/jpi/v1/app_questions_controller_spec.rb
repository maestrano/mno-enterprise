require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppQuestionsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }


    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    let(:app) { build(:app) }
    let(:question_answer_1) { build(:app_answer) }
    let(:question_answer_2) { build(:app_answer) }
    let(:app_question) { build(:app_question, answers: [question_answer_1, question_answer_2]) }
    let(:expected_hash_for_answer_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role)
      question_answer_1.attributes.slice(*attrs).merge({'created_at' => question_answer_1.created_at.as_json, 'updated_at' => question_answer_1.updated_at.as_json})
    end
    let(:expected_hash_for_answer_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role)
      question_answer_2.attributes.slice(*attrs).merge({'created_at' => question_answer_2.created_at.as_json, 'updated_at' => question_answer_2.updated_at.as_json})
    end
    let(:expected_array_for_answers) { [expected_hash_for_answer_1, expected_hash_for_answer_2] }
    let(:expected_hash_for_question) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id app_name user_admin_role answers)
      app_question.attributes.slice(*attrs).merge({'created_at' => app_question.created_at.as_json, 'updated_at' => app_question.updated_at.as_json, 'answers' => expected_array_for_answers})
    end
    let(:expected_hash_for_questions) do
      {
        'app_questions' => [expected_hash_for_question],
        'metadata' => {'pagination' => {'count' => 1}}
      }
    end

    before do
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
    end

    describe 'GET #index' do

      before do
        api_stub_for(get: "/app_questions?filter[reviewable_id]=#{app.id}", response: from_api([app_question]))
      end

      subject { get :index, id: app.id }

      it_behaves_like "jpi v1 protected action"

      it_behaves_like "a paginated action"

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)).to eq(expected_hash_for_questions)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: 1, description: 'A Review', foo: 'bar'} }

      before do
        api_stub_for(post: "/app_questions", response: from_api(app_question))
        api_stub_for(get: "/app_questions/#{app_question.id}", response: from_api(app_question))
      end

      subject { post :create, id: app.id, app_question: params }

      it_behaves_like "jpi v1 protected action"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_question' => expected_hash_for_question)
      end
    end
  end
end
