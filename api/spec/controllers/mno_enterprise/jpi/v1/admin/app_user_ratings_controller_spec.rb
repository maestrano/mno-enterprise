require 'rails_helper'

module MnoEnterprise
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  describe Jpi::V1::Admin::AppUserRatingsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:app_user_rating) { build(:app_user_rating, user: user) }
    before do
      api_stub_for(get: '/app_user_ratings', response: from_api([app_user_rating]))
      api_stub_for(get: "/app_user_ratings/#{app_user_rating.id}", response: from_api(app_user_rating))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    def partial_hash_for_app_user_rating(app_user_rating)
      {
        'id' => app_user_rating.id,
        'rating' => app_user_rating.rating,
        'description' => app_user_rating.description,
        'status' => app_user_rating.status,
        'app_id' => app_user_rating.app_id,
        'app_name' => app_user_rating.app_name,
        'user_id' => app_user_rating.user_id,
        'user_name' => app_user_rating.user_name,
        'organization_id' => app_user_rating.organization_id,
        'organization_name' => app_user_rating.organization_name,
        'created_at' => app_user_rating.created_at,
        'updated_at' => app_user_rating.updated_at,
      }
    end

    def hash_for_app_user_rating(app_user_rating)
      {
        'app_user_rating' => partial_hash_for_app_user_rating(app_user_rating)
      }
    end

    def hash_for_app_user_ratings(app_user_ratings)
      {
        'app_user_ratings' => app_user_ratings.map { |o| partial_hash_for_app_user_rating(o) }
      }
    end


    describe '#index' do
      subject { get :index }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it 'returns a list of app_user_rating' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app_user_ratings([app_user_rating]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: app_user_rating.id }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it 'returns a complete description of the app_user_rating' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app_user_rating(app_user_rating).to_json))
        end
      end
    end


    describe 'PUT #update' do
      subject { put :update, id: app_user_rating.id, app_user_rating: {status: 'rejected'} }

      before do
        sign_in user
        api_stub_for(put: "/app_user_ratings/#{app_user_rating.id}", response: -> { app_user_rating.status = 'rejected'; from_api(app_user_rating) })
      end

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        # Test that the app_user_rating is updated by testing the api endpoint was called
        it { expect(app_user_rating.status).to eq('rejected') }
      end
    end


  end
end
