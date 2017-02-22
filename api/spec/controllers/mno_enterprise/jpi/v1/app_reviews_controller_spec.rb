require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppReviewsController, type: :controller do
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
    let(:app_review) { build(:app_review) }
    let(:expected_hash_for_review) do
      attrs = %w(id rating description status user_id user_name organization_id organization_name app_id app_name json.user_admin_role user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)
      app_review.attributes.slice(*attrs).merge({'created_at' => app_review.created_at.as_json, 'updated_at' => app_review.updated_at.as_json})
    end
    let(:expected_hash_for_reviews) do
      {
        'app_reviews' => [expected_hash_for_review],
      }
    end

    before do
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
    end

    describe 'GET #index' do

      before do
        api_stub_for(get: "/app_reviews?filter[reviewable_id]=#{app.id}", response: from_api([app_review]))
      end

      subject { get :index, id: app.id }

      it_behaves_like "jpi v1 protected action"

      it_behaves_like "a paginated action"

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)).to eq(expected_hash_for_reviews)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: 1, description: 'A Review', rating: 5, foo: 'bar'} }
      let(:app_review) { build(:app_review) }

      before do
        api_stub_for(post: "/app_reviews", response: from_api(app_review))
        api_stub_for(get: "/app_reviews/#{app_review.id}", response: from_api(app_review))
      end

      subject { post :create, id: app.id, app_review: params }

      it_behaves_like "jpi v1 protected action"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_review' => expected_hash_for_review)
      end

      it 'renders the new average rating' do
        expect(JSON.parse(subject.body)).to include('average_rating' => app.average_rating)
      end
    end

    describe 'PATCH #update', focus: true do
      let(:params) { {description: 'A Review 2', rating: 1} }
      let(:app_review) { build(:app_review, user_id: user.id) }

      before do
        api_stub_for(put: "/app_reviews/#{app_review.id}", response: from_api(app_review))
        api_stub_for(get: "/app_reviews/#{app_review.id}", response: from_api(app_review))
      end

      subject { put :update, id: app.id, review_id: app_review.id, app_review: params }

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_review' => expected_hash_for_review)
        expect(JSON.parse(subject.body)).to include('average_rating' => app.average_rating)
      end
    end

    describe 'DELETE #destroy', focus: true do
      let(:app_review) { build(:app_review, user_id: user.id) }

      before do
        api_stub_for(delete: "/app_reviews/#{app_review.id}", response: from_api(app_review))
        api_stub_for(get: "/app_reviews/#{app_review.id}", response: from_api(app_review))
      end

      subject { delete :destroy, id: app.id, review_id: app_review.id }

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_review' => expected_hash_for_review)
        expect(JSON.parse(subject.body)).to include('average_rating' => app.average_rating)
      end
    end
  end
end
