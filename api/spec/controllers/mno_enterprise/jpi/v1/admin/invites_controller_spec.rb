require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::InvitesController do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    render_views
    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    let!(:current_user_stub) { stub_user(user) }
    before do
      sign_in user
    end

    let(:organization) { build(:organization, orga_relations: []) }
    let(:invitee) { build(:user) }
    let(:invite) { build(:orga_invite, user: invitee, organization: organization, status: 'staged') }

    # Stub ActionMailer
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    before { allow(message_delivery).to receive(:deliver_now).with(no_args) }

    before { stub_audit_events }

    # API stubs
    before do
      allow(MnoEnterprise::User).to receive(:find) do |user_id|
        case user_id.to_i
        when user.id then user
        when invitee.id then invitee
        end
      end
      stub_api_v2(:get, "/users/#{invitee.id}", invitee)
      stub_api_v2(:get, "/organizations/#{organization.id}", organization, [:orga_relations])
      stub_api_v2(:get, '/orga_invites', [invite], [:user, :organization, :team, :referrer], {filter: {organization_id: organization.id, user_id: invitee.id, 'status.in': 'staged,pending'}, page:{number:1, size: 1}})
      #reload
      stub_api_v2(:get, "/orga_invites/#{invite.id}", invite, [:user])
      stub_api_v2(:patch, "/orga_invites/#{invite.id}", invite)
    end

    # unconfirmed
    describe 'POST #create' do
      subject { post :create, user_id: invitee.id, organization_id: organization.id }

      before { allow(SystemNotificationMailer).to receive(:organization_invite).and_return(message_delivery) }
      it_behaves_like 'a jpi v1 admin action'

      context 'existing user' do
        it 'sends the invitation email' do
          expect(SystemNotificationMailer).to receive(:organization_invite).and_return(message_delivery)
          subject
          expect(response).to be_success
        end
      end

      context 'new user'  do
        let(:invitee) { build(:user, confirmed_at: nil) }

        it 'sends the confirmation instructions' do
          expect_any_instance_of(User).to receive(:resend_confirmation_instructions)
          subject
        end
      end
    end
  end
end
