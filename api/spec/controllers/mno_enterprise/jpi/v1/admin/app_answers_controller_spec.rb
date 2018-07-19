require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppAnswersController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin, orga_relations: [orga_relation]) }
    let!(:orga_relation) { build(:orga_relation) }
    let!(:current_user_stub) { stub_user(user) }
    let(:question) { build(:question) }

    let(:expected_hash_for_answer) {
      hash_for_review(answer, ANSWER_ATTRIBUTES).merge('type' => 'Answer', 'question_id' => answer.parent_id)
    }
    ANSWER_ATTRIBUTES = %w(id description status user_id user_name organization_id organization_name app_id app_name)

    before { sign_in user }

    let(:answer) { build(:answer, parent_id: question.id) }

    describe 'POST #create', focus: true do
      let(:params) { {description: 'A Review'} }

      before do
        stub_api_v2(:get, "/questions/#{question.id}", question)
        stub_api_v2(:post, '/answers', answer)
      end

      subject { post :create, app_answer: params, question_id: question.id }

      it_behaves_like "an unauthorized route for support users"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)['app_answer']).to eq(expected_hash_for_answer)
      end
    end
  end
end
