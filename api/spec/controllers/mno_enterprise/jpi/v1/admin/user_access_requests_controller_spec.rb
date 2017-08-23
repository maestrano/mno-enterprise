require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::UserAccessRequestsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    let(:user) { build(:user, :admin) }

    let(:requested_user) { build(:user, :admin) }

    # Stub ActionMailer
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    before { allow(message_delivery).to receive(:deliver_now).with(no_args) }

    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      stub_api_v2(:get, "/users/#{requested_user.id}", requested_user)
      sign_in user
      stub_audit_events
    end
    let!(:stub) { stub_api_v2(:post, "/user_access_requests", requested_user) }

    describe 'POST #create' do
      subject { post :create, user_id: requested_user.id }

      before {
        allow(SystemNotificationMailer).to receive(:request_access).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later).with(no_args)
      }
      it_behaves_like 'a jpi v1 admin action'


      it 'sends the invitation email' do
        expect(message_delivery).to receive(:deliver_later).with(no_args)
        subject
        expect(response).to be_success
      end

      it 'create the request' do
        subject
        expect(stub).to have_been_requested
      end
    end
  end
end
