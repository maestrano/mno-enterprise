require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppFeedbacksController, type: :controller do
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
    let(:feedback_comment_1) { build(:app_comment) }
    let(:feedback_comment_2) { build(:app_comment) }
    let(:app_feedback) { build(:app_feedback, comments: [feedback_comment_1, feedback_comment_2]) }
    let(:expected_hash_for_comment_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name user_admin_role)
      feedback_comment_1.attributes.slice(*attrs).merge({'created_at' => feedback_comment_1.created_at.as_json, 'updated_at' => feedback_comment_1.updated_at.as_json})
    end
    let(:expected_hash_for_comment_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name user_admin_role)
      feedback_comment_2.attributes.slice(*attrs).merge({'created_at' => feedback_comment_2.created_at.as_json, 'updated_at' => feedback_comment_2.updated_at.as_json})
    end
    let(:expected_array_for_comments) { [expected_hash_for_comment_1, expected_hash_for_comment_2] }
    let(:expected_hash_for_feedback) do
      attrs = %w(id rating description status user_id user_name organization_id organization_name app_id app_name user_admin_role comments)
      app_feedback.attributes.slice(*attrs).merge({'created_at' => app_feedback.created_at.as_json, 'updated_at' => app_feedback.updated_at.as_json, 'comments' => expected_array_for_comments})
    end
    let(:expected_hash_for_feedbacks) do
      {
        'app_feedbacks' => [expected_hash_for_feedback],
        'metadata' => {'pagination' => {'count' => 1}}
      }
    end

    before do
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
    end

    describe 'GET #index' do

      before do
        api_stub_for(get: "/app_feedbacks?filter[reviewable_id]=#{app.id}", response: from_api([app_feedback]))
      end

      subject { get :index, id: app.id }

      it_behaves_like "jpi v1 protected action"

      it_behaves_like "a paginated action"

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)).to eq(expected_hash_for_feedbacks)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: 1, description: 'A Review', rating: 5, foo: 'bar'} }

      before do
        api_stub_for(post: "/app_feedbacks", response: from_api(app_feedback))
        api_stub_for(get: "/app_feedbacks/#{app_feedback.id}", response: from_api(app_feedback))
      end

      subject { post :create, id: app.id, app_feedback: params }

      it_behaves_like "jpi v1 protected action"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_feedback' => expected_hash_for_feedback)
      end

      it 'renders the new average rating' do
        expect(JSON.parse(subject.body)).to include('average_rating' => app.average_rating)
      end
    end
  end
end
