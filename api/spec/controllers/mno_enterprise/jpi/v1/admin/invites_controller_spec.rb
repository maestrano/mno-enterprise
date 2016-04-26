require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::InvitesController do
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    let(:organization) { FactoryGirl.build(:organization) }
    let(:invitee) { FactoryGirl.build(:user) }
    let(:invite) { FactoryGirl.build(:org_invite, user: invitee, organization: organization, status: 'staged') }

    # Stub ActionMailer
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    before { allow(message_delivery).to receive(:deliver_later).with(no_args) }

    # API stubs
    before do
      api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization))
      api_stub_for(get: "/organizations/#{organization.id}/org_invites?filter[status.in][]=pending&filter[status.in][]=staged&filter[user_id]=#{invitee.id}", response: from_api([invite]))

      allow(MnoEnterprise::User).to receive(:find) do |user_id|
        case user_id.to_i
        when user.id then user
        when invitee.id then invitee
        end
      end

      api_stub_for(put: "/org_invites/#{invite.id}", response: from_api(invite))
    end

    # unconfirmed
    describe 'POST #create' do
      subject { post :create, user_id: invitee.id, organization_id: organization.id }

      context 'existing user' do
        it 'sends the invitation email' do
          expect(SystemNotificationMailer).to receive(:organization_invite).with(invite).and_return(message_delivery)
          subject
          expect(response).to be_success
        end
      end

      context 'new user'  do
        before { invitee.confirmed_at = nil }

        it 'sends the confirmation instructions' do
          expect(invitee).to receive(:resend_confirmation_instructions)
          subject
        end
      end
    end
  end
end
