require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppCommentsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let!(:orga_relation) { build(:orga_relation) }
    let!(:current_user_stub) { stub_user(user) }
    let(:feedback) { build(:feedback) }

    let(:expected_hash_for_comment) {
      hash_for_review(comment, COMMENT_ATTRIBUTES).merge('type' => 'Comment', 'feedback_id' => comment.parent_id)
    }
    COMMENT_ATTRIBUTES = %w(id description status user_id user_name organization_id organization_name app_id app_name)

    before { sign_in user }

    let(:comment) { build(:comment, parent_id: feedback.id) }

    describe 'POST #create', focus: true do
      let(:params) { {description: 'A Review'} }

      before do
        stub_api_v2(:get, "/feedbacks/#{feedback.id}", feedback)
        stub_api_v2(:post, '/comments', comment)
        stub_api_v2(:get, '/orga_relations', [orga_relation], [], {filter: {'user.id': user.id}, page: one_page})
      end

      subject { post :create, app_comment: params, feedback_id: feedback.id }

      it 'renders the new review' do
        expect(JSON.parse(subject.body)['app_comment']).to eq(expected_hash_for_comment)
      end
    end
  end
end
