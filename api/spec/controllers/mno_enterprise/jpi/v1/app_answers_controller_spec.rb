require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppAnswersController, type: :controller do
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
    let(:answer1) { build(:answer, parent_id: 'qid') }
    let(:answer2) { build(:answer, parent_id: 'qid') }

    before do
      stub_api_v2(:get, "/apps/#{app.id}", app)
    end

    describe 'GET #index' do

      before do
        stub_api_v2(:get, '/answers', [answer1, answer2], [], {filter: {parent_id: 'qid', reviewer_type: 'OrgaRelation', reviewable_type: 'App', status: 'approved', reviewable_id: app.id}})
      end

      subject { get :index, id: app.id, parent_id: 'qid' }

      it_behaves_like 'jpi v1 protected action'

      it_behaves_like 'a paginated action'

      it 'renders the list of reviews' do
        subject
        app_answers = JSON.parse(response.body)['app_answers']
        expect(app_answers[0]).to eq(hash_for_answer(answer1))
        expect(app_answers[1]).to eq(hash_for_answer(answer2))
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: organization.id, description: 'A Review', foo: 'bar', question_id: 'qid'} }

      before do
        stub_api_v2(:get, '/orga_relations', [orga_relation], [], {filter: {organization_id: organization.id, user_id: user.id}, page: {number: 1, size: 1}})
        stub_api_v2(:post, '/answers', answer1)
      end

      subject { post :create, id: app.id, app_answer: params }

      it_behaves_like 'jpi v1 protected action'

      it 'renders the new review' do
        expect(JSON.parse(subject.body)['app_answer']).to eq(hash_for_answer(answer1))
      end
    end
  end
end
