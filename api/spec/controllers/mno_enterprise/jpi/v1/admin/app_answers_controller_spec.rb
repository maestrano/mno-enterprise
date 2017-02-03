require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppAnswersController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }


    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:organization) { user.organizations.first }
    let(:question) { build(:app_question) }

    before { api_stub_for(get: "/organization/#{organization.id}", response: from_api(organization)) }
    before { api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization])) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/app_questions/#{question.id}", response: from_api(question)) }
    before { sign_in user }

    let(:answer_1) { build(:app_answer, question_id: 'qid') }
    let(:expected_hash_for_answer_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id question_id app_name)
      answer_1.attributes.slice(*attrs).merge({'type' => 'Answer', 'created_at' => answer_1.created_at.as_json, 'updated_at' => answer_1.updated_at.as_json})
    end

    describe 'POST #create', focus: true do
      let(:params) { {description: 'A Review', foo: 'bar'} }

      before do
        api_stub_for(post: "/app_answers", response: from_api(answer_1))
        api_stub_for(get: "/app_answers/#{answer_1.id}", response: from_api(answer_1))
      end

      subject { post :create, app_answer: params, question_id: question.id }

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_answer' => expected_hash_for_answer_1)
      end
    end
  end
end
