require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::DeletionRequestsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    # Stub model calls
    let(:deletion_request) { build(:deletion_request) }
    let(:user) { build(:user, deletion_requests: [deletion_request]) }
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }

    describe 'POST #create' do
      before {stub_api_v2(:post, '/deletion_requests', deletion_request)}

      subject { post :create }
      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        it 'creates the account deletion_request' do
          subject
        end

        it 'sends the instructions email' do
          message_delivery = instance_double(ActionMailer::MessageDelivery)
          expect(message_delivery).to receive(:deliver_now).with(no_args)

          expect(SystemNotificationMailer).to receive(:deletion_request_instructions)
                                                  .and_return(message_delivery)

          subject
        end
      end
    end

    describe 'PUT #resend' do
      subject { put :resend, id: deletion_request.token }
      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        it 'resends the deletion instructions' do
          message_delivery = instance_double(ActionMailer::MessageDelivery)
          expect(message_delivery).to receive(:deliver_now).with(no_args)

          expect(SystemNotificationMailer).to receive(:deletion_request_instructions)
                                                  .and_return(message_delivery)

          subject
        end
      end
    end

    describe 'DELETE #destroy' do
      before {stub_api_v2(:delete, "/deletion_requests/#{deletion_request.id}")}

      subject { delete :destroy, id: deletion_request.token }
      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        it 'destroys the deletion request' do
          subject
        end
      end
    end

  end
end
