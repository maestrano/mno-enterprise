require 'rails_helper'

module MnoEnterprise
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  describe Jpi::V1::Admin::AppFeedbacksController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:feedback_comment_1) { build(:app_comment) }
    let(:feedback_comment_2) { build(:app_comment) }
    let(:app_feedback) { build(:app_feedback, comments: [feedback_comment_1, feedback_comment_2]) }
    let(:expected_hash_for_comment_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)
      feedback_comment_1.attributes.slice(*attrs).merge({'created_at' => feedback_comment_1.created_at.as_json, 'updated_at' => feedback_comment_1.updated_at.as_json})
    end
    let(:expected_hash_for_comment_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)
      feedback_comment_2.attributes.slice(*attrs).merge({'created_at' => feedback_comment_2.created_at.as_json, 'updated_at' => feedback_comment_2.updated_at.as_json})
    end
    let(:expected_array_for_comments) { [expected_hash_for_comment_1, expected_hash_for_comment_2] }
    let(:expected_hash_for_feedback) do
      attrs = %w(id rating description status user_id user_name organization_id organization_name app_id app_name user_admin_role comments edited edited_by_name edited_by_admin_role edited_by_id)
      app_feedback.attributes.slice(*attrs).merge({'created_at' => app_feedback.created_at.as_json, 'updated_at' => app_feedback.updated_at.as_json, 'comments' => expected_array_for_comments})
    end
    let(:expected_hash_for_feedbacks) do
      {
        'app_feedbacks' => [expected_hash_for_feedback],
      }
    end
    before do
      api_stub_for(get: '/app_feedbacks', response: from_api([app_feedback]))
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
          expect(JSON.parse(response.body)).to eq(expected_hash_for_feedbacks)
        end
      end
    end

  end
end
