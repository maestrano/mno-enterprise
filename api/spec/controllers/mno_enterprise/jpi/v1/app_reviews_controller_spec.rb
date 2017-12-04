require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppReviewsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }


    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation, user: user, organization: organization) }
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }

    let(:app) { build(:app) }
    let(:review) { build(:review) }
    let(:expected_hash_for_review) { hash_for_review(review).merge('rating' => review.rating) }

    before do
      stub_api_v2(:get, "/apps/#{app.id}", app)
    end

    let(:data) { JSON.parse(subject.body) }


    describe 'GET #index' do

      before do
        stub_api_v2(:get, '/reviews', [review], [], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App', status: 'approved', reviewable_id: app.id}})
      end

      subject { get :index, id: app.id }

      it_behaves_like 'jpi v1 protected action'

      it_behaves_like 'a paginated action'

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)['app_reviews'][0]).to eq(expected_hash_for_review)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: organization.id, description: 'A Review', rating: 5} }
      before do
        stub_orga_relation(user, organization, orga_relation)
        stub_api_v2(:post, '/reviews', review)
      end

      subject { post :create, id: app.id, app_review: params }

      it_behaves_like 'jpi v1 protected action'
      let(:data) { JSON.parse(subject.body) }
      it 'renders the new review' do
        expect(data['app_review']).to include(expected_hash_for_review)
      end

      it 'renders the new average rating' do
        expect(data['average_rating']).to eq(app.average_rating)
      end
    end

    describe 'PATCH #update', focus: true do
      let(:params) { {description: 'A Review 2', rating: 1} }
      let(:review) { build(:review, user_id: user.id) }
      before do
        stub_api_v2(:get, "/reviews/#{review.id}", review)
      end
      let!(:patch_stub) { stub_api_v2(:patch, "/reviews/#{review.id}", review) }

      subject { put :update, id: app.id, review_id: review.id, app_review: params }

      it {
        subject
        expect(patch_stub).to have_been_requested
      }

      it 'renders the new review' do
        expect(data['app_review']).to include(expected_hash_for_review)
      end

      it 'renders the new average rating' do
        expect(data['average_rating']).to eq(app.average_rating)
      end
    end

    describe 'DELETE #destroy', focus: true do
      let(:review) { build(:review, user_id: user.id) }
      let!(:delete_stub) { stub_api_v2(:delete, "/reviews/#{review.id}") }
      before do
        stub_api_v2(:get, "/reviews/#{review.id}", review)
      end

      subject { delete :destroy, id: app.id, review_id: review.id }

      it 'renders the new review' do
        expect(data['average_rating']).to eq(app.average_rating)
      end

      it {
        subject
        expect(delete_stub).to have_been_requested
      }

    end
  end
end
