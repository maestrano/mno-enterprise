require 'rails_helper'

module MnoEnterprise
  RSpec.describe SystemNotificationMailer do
    subject { SystemNotificationMailer }
    before { MnoEnterprise::Engine.routes.default_url_options = {host: 'http://localhost:3000'} }
    let(:routes) { MnoEnterprise::Engine.routes.url_helpers }
    let(:user) { build(:user) }
    let(:token) { "1sd5f323S1D5AS" }
    let(:deletion_request) { build(:deletion_request) }

    # Commonly used mandrill variables
    def user_vars(user)
      { first_name: user.name, last_name: user.surname, full_name: "#{user.name} #{user.surname}".strip }
    end
    
    def invite_vars(org_invite)
      new_user = !org_invite.user.confirmed?
      
      {
        organization: org_invite.organization.name,
        team: org_invite.team ? org_invite.team.name : nil,
        ref_first_name: org_invite.referrer.name,
        ref_last_name: org_invite.referrer.surname,
        ref_full_name: "#{org_invite.referrer.name} #{org_invite.referrer.surname}".strip,
        ref_email: org_invite.referrer.email,
        invitee_first_name: new_user ? nil : org_invite.user.name,
        invitee_last_name: new_user ? nil : org_invite.user.surname,
        invitee_full_name: new_user ? nil : "#{org_invite.user.name} #{org_invite.user.surname}".strip,
        invitee_email: org_invite.user.email,
      }
    end
    
    describe 'confirmation_instructions' do
      describe 'new user' do
        it 'sends the right email' do
          expect(MnoEnterprise::MailClient).to receive(:deliver).with('confirmation-instructions',
            SystemNotificationMailer::DEFAULT_SENDER,
            { name: "#{user.name} #{user.surname}".strip, email: user.email },
            user_vars(user).merge(confirmation_link: routes.user_confirmation_url(confirmation_token: token))
          )
        
          subject.confirmation_instructions(user,token).deliver_now
        end
      end
      
      describe 'existing user with new email address' do
        before { allow_any_instance_of(MnoEnterprise::User).to receive(:confirmed?).and_return(true) }
        before { allow_any_instance_of(MnoEnterprise::User).to receive(:unconfirmed_email?).and_return(true) }
        
        it 'sends the right email' do
          expect(MnoEnterprise::MailClient).to receive(:deliver).with('reconfirmation-instructions',
            SystemNotificationMailer::DEFAULT_SENDER,
            { name: "#{user.name} #{user.surname}".strip, email: user.email },
            user_vars(user).merge(confirmation_link: routes.user_confirmation_url(confirmation_token: token))
          )
        
          subject.confirmation_instructions(user,token).deliver_now
        end
      end
      
    end
    
    describe 'reset_password_instructions' do
      it 'sends the right email' do
        expect(MnoEnterprise::MailClient).to receive(:deliver).with('reset-password-instructions',
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(reset_password_link: routes.edit_user_password_url(reset_password_token: token))
        )
        
        subject.reset_password_instructions(user,token).deliver_now
      end
    end
    
    describe 'unlock_instructions' do
      it 'sends the right email' do
        expect(MnoEnterprise::MailClient).to receive(:deliver).with('unlock-instructions',
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(unlock_link: routes.user_unlock_url(unlock_token: token))
        )
        
        subject.unlock_instructions(user,token).deliver_now
      end
    end
    
    describe 'organization_invite' do
      let(:invitee) { build(:user) }
      let(:org_invite) { build(:org_invite, user: invitee, referrer: user) }
      
      context 'when invitee is a confirmed user' do
        it 'sends the right email' do
          expect(MnoEnterprise::MailClient).to receive(:deliver).with('organization-invite-existing-user',
            SystemNotificationMailer::DEFAULT_SENDER,
            { name: "#{invitee.name} #{invitee.surname}".strip, email: invitee.email },
            invite_vars(org_invite).merge(confirmation_link: routes.org_invite_url(id: org_invite.id, token: org_invite.token))
          )
        
          subject.organization_invite(org_invite).deliver_now
        end
      end
      
      context 'when inviteee is an unconfirmed user' do
        let(:invitee) { build(:user, :unconfirmed) }
        
        it 'sends the right email' do
          expect(MnoEnterprise::MailClient).to receive(:deliver).with('organization-invite-new-user',
            SystemNotificationMailer::DEFAULT_SENDER,
            { email: invitee.email },
            invite_vars(org_invite).merge(confirmation_link: routes.user_confirmation_url(confirmation_token: invitee.confirmation_token))
          )
        
          subject.organization_invite(org_invite).deliver_now
        end
      end

    end

    describe 'deletion_request_instructions' do
      it 'sends the correct email' do
        expect(MnoEnterprise::MailClient).to receive(:deliver).with('deletion-request-instructions',
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(terminate_account_link: routes.deletion_request_url(deletion_request))
        )

        subject.deletion_request_instructions(user,deletion_request).deliver_now
      end
    end
  end
end
