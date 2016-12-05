require 'rails_helper'

module MnoEnterprise
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  describe Jpi::V1::Admin::AppReviewsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:app_review) { build(:app_review, user: user) }
    before do
      api_stub_for(get: '/app_reviews', response: from_api([app_review]))
      api_stub_for(get: "/app_reviews/#{app_review.id}", response: from_api(app_review))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    def partial_hash_for_app_review(app_review)
      {
        'id' => app_review.id,
        'rating' => app_review.rating,
        'description' => app_review.description,
        'status' => app_review.status,
        'app_id' => app_review.app_id,
        'app_name' => app_review.app_name,
        'user_id' => app_review.user_id,
        'user_name' => app_review.user_name,
        'organization_id' => app_review.organization_id,
        'organization_name' => app_review.organization_name,
        'created_at' => app_review.created_at,
        'updated_at' => app_review.updated_at,
      }
    end

    def hash_for_app_review(app_review)
      {
        'app_review' => partial_hash_for_app_review(app_review)
      }
    end

    def hash_for_app_reviews(app_reviews)
      {
        'app_reviews' => app_reviews.map { |o| partial_hash_for_app_review(o) }
      }
    end


    describe '#index' do
      subject { get :index }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it 'returns a list of app_review' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app_reviews([app_review]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: app_review.id }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it 'returns a complete description of the app_review' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app_review(app_review).to_json))
        end
      end
    end


    describe 'PUT #update' do
      subject { put :update, id: app_review.id, app_review: {status: 'rejected'} }

      before do
        sign_in user
        api_stub_for(put: "/app_reviews/#{app_review.id}", response: -> { app_review.status = 'rejected'; from_api(app_review) })
      end

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        # Test that the app_review is updated by testing the api endpoint was called
        it { expect(app_review.status).to eq('rejected') }
      end
    end


  end
end
