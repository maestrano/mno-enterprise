require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppAnswersController, type: :controller do
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
    let(:answer_1) { build(:app_answer, question_id: 'qid') }
    let(:answer_2) { build(:app_answer, question_id: 'qid') }
    let(:expected_hash_for_answer_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role)
      answer_1.attributes.slice(*attrs).merge({'created_at' => answer_1.created_at.as_json, 'updated_at' => answer_1.updated_at.as_json})
    end
    let(:expected_hash_for_answer_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name user_admin_role)
      answer_2.attributes.slice(*attrs).merge({'created_at' => answer_2.created_at.as_json, 'updated_at' => answer_2.updated_at.as_json})
    end
    let(:expected_hash_for_answers) do
      {
        'app_answers' => [expected_hash_for_answer_1, expected_hash_for_answer_2],
      }
    end

    before do
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
    end

    describe 'GET #index' do

      before do
        api_stub_for(get: "/app_answers?filter[question_id]=qid&filter[status]=approved", response: from_api([expected_hash_for_answer_1, expected_hash_for_answer_2]))
      end

      subject { get :index, id: app.id, question_id: 'qid' }

      it_behaves_like "jpi v1 protected action"

      it_behaves_like "a paginated action"

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)).to eq(expected_hash_for_answers)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: 1, description: 'A Review', foo: 'bar', question_id: 'qid'} }

      before do
        api_stub_for(post: "/app_answers", response: from_api(answer_1))
        api_stub_for(get: "/app_answers/#{answer_1.id}", response: from_api(answer_1))
      end

      subject { post :create, id: app.id, app_answer: params }

      it_behaves_like "jpi v1 protected action"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_answer' => expected_hash_for_answer_1)
      end
    end
  end
end
