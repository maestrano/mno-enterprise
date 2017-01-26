require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AppCommentsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }


    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    let(:comment_1) { build(:app_comment, feedback_id: 'fid') }
    let(:expected_hash_for_comment_1) do
      attrs = %w(id description status user_id user_name organization_id organization_name app_id feedback_id app_name)
      comment_1.attributes.slice(*attrs).merge({'created_at' => comment_1.created_at.as_json, 'updated_at' => comment_1.updated_at.as_json})
    end

    describe 'POST #create', focus: true do
      let(:params) { {description: 'A Review', foo: 'bar', feedback_id: 'fid'} }

      before do
        api_stub_for(post: "/app_comments", response: from_api(comment_1))
        api_stub_for(get: "/app_comments/#{comment_1.id}", response: from_api(comment_1))
      end

      subject { post :create, app_comment: params }

      it 'renders the new review' do
        expect(JSON.parse(subject.body)).to include('app_comment' => expected_hash_for_comment_1)
      end
    end
  end
end
