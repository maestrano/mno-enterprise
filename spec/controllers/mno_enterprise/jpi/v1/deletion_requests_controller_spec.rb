require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::DeletionRequestsController, type: :controller do
    include JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub user and user call
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }


    let(:deletion_request) { build(:deletion_request) }

    let(:valid_attributes) { {} }

    describe 'POST #create' do
      before { api_stub_for(post: "/deletion_requests", response: from_api(deletion_request)) }

      subject { post :create, deletion_request: valid_attributes }
      it_behaves_like "jpi v1 protected action"

      context 'success' do
        # before { subject }

        it 'creates the account deletion_request'

        it 'sends the instructions email'
      end
    end

  end
end
