require 'rails_helper'

module MnoEnterprise

  describe Jpi::V1::Admin::AppReviewsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    include MnoEnterprise::TestingSupport::ReviewsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    let(:user) { build(:user, :admin, orga_relations: [orga_relation]) }
    let!(:orga_relation) { build(:orga_relation) }
    let!(:current_user_stub) { stub_user(user) }
    let(:review) { build(:review) }
    let!(:get_reviews_stub) { stub_api_v2(:get, '/reviews', [review], [], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App'}}) }

    before do
      sign_in user
    end
    REVIEW_ATTRIBUTE = %w(id rating description status app_id app_name user_id user_name organization_id organization_name)
    let(:expected_hash) { hash_for_review(review, REVIEW_ATTRIBUTE).merge('type' => 'Review') }

    describe '#index' do
      subject { get :index }
      it_behaves_like 'a jpi v1 admin action'
      context 'success' do
        before { subject }
        it 'returns a list of app_review' do
          expect(response).to be_success
          expect(JSON.parse(response.body)['app_reviews'][0]).to eq(expected_hash)
        end
        it { expect(get_reviews_stub).to have_been_requested }
      end
    end

    describe 'GET #show' do
      subject { get :show, id: review.id }
      it_behaves_like 'a jpi v1 admin action'
      let!(:get_stub) { stub_api_v2(:get, "/reviews/#{review.id}", review) }
      context 'success' do
        before { subject }
        it 'returns a complete description of the app_review' do
          expect(response).to be_success
          expect(JSON.parse(response.body)['app_review']).to eq(expected_hash)
        end
        it { expect(get_stub).to have_been_requested }
      end
    end

    describe 'PUT #update' do
      let(:review) { build(:feedback) }
      subject { put :update, id: review.id, app_review: {status: 'rejected'} }
      let!(:patch_stub) { stub_api_v2(:patch, "/feedbacks/#{review.id}", review) }
      let!(:get_stub) { stub_api_v2(:get, "/reviews/#{review.id}", review) }
      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { subject }
        it { expect(response).to be_success }
        it { expect(get_stub).to have_been_requested }
        it { expect(patch_stub).to have_been_requested }
      end
    end
  end
end
