require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppFeedbacksController, type: :controller do
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
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    before { sign_in user }

    let(:app) { build(:app) }
    let(:feedback_id) { '1' }
    let(:feedback_comment1) { build(:comment, parent_id: feedback_id) }
    let(:feedback_comment2) { build(:comment, parent_id: feedback_id) }
    let(:feedback) { build(:feedback, id: feedback_id, comments: [feedback_comment1, feedback_comment2]) }


    before do
      stub_api_v2(:get, "/apps/#{app.id}", app)
    end

    describe 'GET #index' do

      before do
        stub_api_v2(:get, '/feedbacks', [feedback], [:comments], {filter: {reviewer_type: 'OrgaRelation', reviewable_type: 'App', status: 'approved', reviewable_id: app.id}})
      end

      subject { get :index, id: app.id }

      it_behaves_like 'jpi v1 protected action'

      it_behaves_like 'a paginated action'

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)['app_feedbacks'][0]).to eq(hash_for_feedback(feedback))
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: organization.id, description: 'A Review', rating: 5} }
      let(:feedback) { build(:feedback, id: feedback_id, comments: []) }
      before do
        stub_api_v2(:get, '/orga_relations', [orga_relation], [], {filter: {organization_id: organization.id, user_id: user.id}, page: {number: 1, size: 1}})
        stub_api_v2(:post, '/feedbacks', feedback)
      end

      subject { post :create, id: app.id, app_feedback: params }

      it_behaves_like 'jpi v1 protected action'
      let(:data) { JSON.parse(subject.body) }
      it 'renders the new review' do
        expect(data['app_feedback']).to include(hash_for_feedback(feedback))
      end

      it 'renders the new average rating' do
        expect(data['average_rating']).to eq(app.average_rating)
      end
    end
  end
end
