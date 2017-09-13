require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppFeedbacksController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    FEEDBACK_ATTRIBUTE = %w(id description status app_id app_name user_id user_name organization_id organization_name)

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation, user: user, organization: organization) }
    let!(:current_user_stub) { stub_user(user) }
    let(:app) { build(:app) }
    let(:feedback_id) { '1' }
    let(:feedback_comment1) { build(:comment, parent_id: feedback_id) }
    let(:feedback_comment2) { build(:comment, parent_id: feedback_id) }
    let(:feedback) { build(:feedback, id: feedback_id, comments: [feedback_comment1, feedback_comment2]) }

    let(:feedback_hash) {
      hash = hash_for_feedback(feedback, FEEDBACK_ATTRIBUTE)
      hash[:comments].each { |c| c[:type] = 'Comment' }
      hash[:type] = 'Feedback'
      hash
    }

    before do
      sign_in user
      stub_api_v2(:get, '/feedbacks', [feedback], [:comments], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App'}})
    end

    describe '#index' do
      subject { get :index }
      it_behaves_like 'a jpi v1 admin action'
      context 'success' do
        before { subject }
        it 'returns a list of app_feedbacks' do
          expect(response).to be_success
          expect(JSON.parse(response.body)['app_feedbacks'][0]).to eq(feedback_hash)
        end
      end
    end
  end
end
