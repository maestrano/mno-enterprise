require 'rails_helper'

module MnoEnterprise
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  describe Jpi::V1::Admin::AppQuestionsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:question_answer_1) { build(:app_answer) }
    let(:question_answer_2) { build(:app_answer) }
    let(:app_question) { build(:app_question, answers: [question_answer_1, question_answer_2]) }
    let(:expected_hash_for_answer_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)
      question_answer_1.attributes.slice(*attrs).merge({'created_at' => question_answer_1.created_at.as_json, 'updated_at' => question_answer_1.updated_at.as_json})
    end
    let(:expected_hash_for_answer_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)
      question_answer_2.attributes.slice(*attrs).merge({'created_at' => question_answer_2.created_at.as_json, 'updated_at' => question_answer_2.updated_at.as_json})
    end
    let(:expected_array_for_answers) { [expected_hash_for_answer_1, expected_hash_for_answer_2] }
    let(:expected_hash_for_question) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id app_name user_admin_role answers edited edited_by_name edited_by_admin_role edited_by_id)
      app_question.attributes.slice(*attrs).merge({'created_at' => app_question.created_at.as_json, 'updated_at' => app_question.updated_at.as_json, 'answers' => expected_array_for_answers})
    end
    let(:expected_hash_for_questions) do
      {
        'app_questions' => [expected_hash_for_question],
      }
    end
    before do
      api_stub_for(get: '/app_questions', response: from_api([app_question]))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe '#index' do
      subject { get :index }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it 'returns a list of app_feedbacks' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(expected_hash_for_questions)
        end
      end
    end

  end
end
