require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::DeletionRequestsController, type: :controller do
    include JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub user and user call
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    let(:deletion_request) { build(:deletion_request) }

    describe 'POST #create' do
      before { api_stub_for(post: "/deletion_requests", response: from_api(deletion_request)) }

      subject { post :create }
      it_behaves_like "jpi v1 protected action"

      context 'success' do
        it 'creates the account deletion_request' do
          subject
          expect(assigns(:deletion_request).user).to eq(user)
        end

        it 'sends the instructions email' do
          message_delivery = instance_double(ActionMailer::MessageDelivery)
          expect(message_delivery).to receive(:deliver_now).with(no_args)

          expect(SystemNotificationMailer).to receive(:deletion_request_instructions)
            .with(user, deletion_request)
            .and_return(message_delivery)

          subject
        end
      end
    end

  end
end
