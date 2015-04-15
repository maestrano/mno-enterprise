require 'rails_helper'

module MnoEnterprise
  RSpec.describe SystemNotificationMailer do
    subject { SystemNotificationMailer }
    let(:routes) { MnoEnterprise::Engine.routes.url_helpers }
    let(:user) { build(:user) }
    let(:token) { "1sd5f323S1D5AS" }
    let(:host) { 'http://localhost:3000' }
    
    # Commonly used mandrill variables
    def user_vars(user)
      { first_name: user.name, last_name: user.surname, full_name: "#{user.name} #{user.surname}".strip }
    end
    
    describe 'confirmation_instructions' do
      it 'sends the right email' do
        expect(MandrillClient).to receive(:deliver).with(:confirmation_instructions,
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(confirmation_link: routes.user_confirmation_url(host: host, confirmation_token: token))
        )
        
        subject.confirmation_instructions(user,token).deliver_now
      end
    end
    
    describe 'reset_password_instructions' do
      it 'sends the right email' do
        expect(MandrillClient).to receive(:deliver).with(:reset_password_instructions,
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(reset_password_link: routes.edit_user_password_url(host: host, reset_password_token: token))
        )
        
        subject.reset_password_instructions(user,token).deliver_now
      end
    end
    
    describe 'unlock_instructions' do
      it 'sends the right email' do
        expect(MandrillClient).to receive(:deliver).with(:unlock_instructions,
          SystemNotificationMailer::DEFAULT_SENDER,
          { name: "#{user.name} #{user.surname}".strip, email: user.email },
          user_vars(user).merge(unlock_link: routes.user_unlock_url(host: host, unlock_token: token))
        )
        
        subject.unlock_instructions(user,token).deliver_now
      end
    end
  end
end