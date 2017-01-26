require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AppCommentsController, type: :controller do
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
    let(:comment_1) { build(:app_comment, feedback_id: 'fid') }
    let(:comment_2) { build(:app_comment, feedback_id: 'fid') }
    let(:expected_hash_for_comment_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name)
      comment_1.attributes.slice(*attrs).merge({'created_at' => comment_1.created_at.as_json, 'updated_at' => comment_1.updated_at.as_json})
    end
    let(:expected_hash_for_comment_2) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name)
      comment_2.attributes.slice(*attrs).merge({'created_at' => comment_2.created_at.as_json, 'updated_at' => comment_2.updated_at.as_json})
    end
    let(:expected_hash_for_comments) do
      {
        'app_comments' => [expected_hash_for_comment_1, expected_hash_for_comment_2],
        'metadata' => {'pagination' => {'count' => 2}}
      }
    end

    before do
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
    end

    describe 'GET #index' do

      before do
        api_stub_for(get: "/app_comments?filter[feedback_id]=fid&filter[status]=approved", response: from_api([expected_hash_for_comment_1, expected_hash_for_comment_2]))
      end

      subject { get :index, id: app.id, feedback_id: 'fid' }

      it_behaves_like "jpi v1 protected action"

      it_behaves_like "a paginated action"

      it 'renders the list of reviews' do
        subject
        expect(JSON.parse(response.body)).to eq(expected_hash_for_comments)
      end
    end

    describe 'POST #create', focus: true do
      let(:params) { {organization_id: 1, description: 'A Review', foo: 'bar', feedback_id: 'fid'} }

      before do
        api_stub_for(post: "/app_comments", response: from_api(comment_1))
        api_stub_for(get: "/app_comments/#{comment_1.id}", response: from_api(comment_1))
      end

      subject { post :create, id: app.id, app_comment: params }

      it_behaves_like "jpi v1 protected action"

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_comment' => expected_hash_for_comment_1)
      end
    end
  end
end
