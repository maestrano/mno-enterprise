require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::UserAccessRequestsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before do
      Timecop.freeze(Time.local(1985))
    end

    after do
      Timecop.return
    end

    #===============================================
    # Assignments
    #===============================================
    let!(:current_user_stub) { stub_user(user) }
    let(:user_access_request) { build(:user_access_request) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    let!(:user) { build(:user, user_access_requests: []) }
    before { sign_in user }
    #===============================================
    # Specs
    #===============================================
    describe 'GET #index' do
      before { stub_api_v2(:get, "/user_access_requests", [user_access_request], [:requester], { filter: { user_id: user.id, status: 'requested', 'created_at.gt': MnoEnterprise::UserAccessRequest::EXPIRATION_TIMEOUT.ago } }) }
      subject { get :index }
      it_behaves_like 'jpi v1 protected action'
    end

    describe 'POST #create' do
      before { stub_audit_events }
      let!(:stubs) {
        [
          stub_api_v2(:post, "/user_access_requests", user_access_request),
          stub_api_v2(:get, "/users/#{user.id}", user, [:user_access_requests, :'user_access_requests.requester']),
          stub_api_v2(:get, "/user_access_requests/#{user_access_request.id}", user_access_request, [:requester])
        ]
      }
      subject { post :create, access_duration: 'UNTIL_REVOKED' }
      it_behaves_like 'jpi v1 protected action'

      context 'with existing pending requests' do
        let(:requester){build(:user)}
        let(:existing_user_access_request) { build(:user_access_request, requester: requester) }
        let!(:user) { build(:user, user_access_requests: [existing_user_access_request]) }
        before do
          stub_api_v2(:get, "/users/#{user.id}", user)
          stub_api_v2(:get, "/users/#{requester.id}", requester)
          expect(SystemNotificationMailer).to receive(:access_approved_all).with(user.id, requester.id, 'UNTIL_REVOKED' ) { message_delivery }
          expect(message_delivery).to receive(:deliver_later).with(no_args)
        end
        let!(:stub) { stub_api_v2(:delete, "/user_access_requests/#{existing_user_access_request.id}") }
        it {subject; expect(stub).to have_been_requested }
      end
    end

    describe 'PUT #deny' do
      before {
        stub_audit_events
        allow(SystemNotificationMailer).to receive(:access_denied).with(user_access_request.id) { message_delivery }
        allow(message_delivery).to receive(:deliver_later).with(no_args)
        stub_api_v2(:get, "/user_access_requests/#{user_access_request.id}", user_access_request, [:requester])
        stub_api_v2(:get, "/user_access_requests/#{user_access_request.id}", user_access_request)
        stub
      }

      let!(:stub) { stub_api_v2(:patch, "/user_access_requests/#{user_access_request.id}/deny", user_access_request, [], {}) }

      subject { put :deny, id: user_access_request.id }

      it_behaves_like 'jpi v1 protected action'

      it 'sends the email' do
        expect(message_delivery).to receive(:deliver_later).with(no_args)
        expect(subject).to be_successful
      end

      it 'sends the request' do
        subject
        expect(stub).to have_been_requested
      end

    end

    describe 'PUT #approve' do
      before {
        stub_audit_events
        sign_in user
        allow(SystemNotificationMailer).to receive(:access_approved).with(user_access_request.id) { message_delivery }
        allow(message_delivery).to receive(:deliver_later).with(no_args)
        stub_api_v2(:get, "/user_access_requests/#{user_access_request.id}", user_access_request, [:requester])
        stub_api_v2(:get, "/user_access_requests/#{user_access_request.id}", user_access_request)
      }

      let!(:stub) { stub_api_v2(:patch, "/user_access_requests/#{user_access_request.id}/approve", user_access_request, [], {}) }

      subject { put :approve, id: user_access_request.id }

      it_behaves_like 'jpi v1 protected action'

      it 'sends the email' do
        expect(message_delivery).to receive(:deliver_later).with(no_args)
        expect(subject).to be_successful
      end

      it 'sends the request' do
        subject
        expect(stub).to have_been_requested
      end
    end
  end
end
