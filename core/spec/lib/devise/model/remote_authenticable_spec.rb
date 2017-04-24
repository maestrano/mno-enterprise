require "rails_helper"

RSpec.describe Devise::Models::RemoteAuthenticatable do
  let(:user) { build(:user, email: 'test@maestrano.com', password: 'oldpass') }

    before do
      stub_api_v2(:get, '/users', [], [], {filter: {email: 'test@maestrano.com'}, page: {number: 1, size: 1}})
      stub_api_v2(:post, '/users', user)
    end

    describe 'Sends an email on password update' do
    let(:confirmation_token){'1e243fa1180e32f3ec66a648835d1fbca7912223a487eac36be22b095a01b5a5'}
    before{
      Devise.token_generator
      stub_api_v2(:get, '/users', user, [], {filter: {confirmation_token: confirmation_token}})
      allow_any_instance_of(Devise::TokenGenerator).to receive(:digest).and_return(confirmation_token)
      allow_any_instance_of(Devise::TokenGenerator).to receive(:generate).and_return(confirmation_token)
    }

    subject { user.update(updates) }

    context 'when password change notifications are enabled' do
      before { user.class.send_password_change_notification = true }

      context 'when the user is confirmed' do
        let(:user) { build(:user, email: 'test@maestrano.com', password: 'oldpass', confirmed_at: nil) }
        let(:updates) { {password: 'newpass', password_confirmation: 'newpass', confirmed_at: Time.current} }

        it 'does not send an email' do
          expect(user).not_to receive(:send_devise_notification)
          subject
        end
      end

      context 'when the password is changed' do
        let(:updates) { {password: 'newpass', password_confirmation: 'newpass'} }

        it 'sends an email' do
          expect(user).to receive(:send_devise_notification).with(:password_change)
          subject
        end
      end
    end

    context 'when password does not change notifications are disabled' do
      before { user.class.send_password_change_notification = false }

      context 'when the password is not updated' do
        let(:updates) { {name: 'Bob'} }

        it 'does not send an email' do
          expect(user).not_to receive(:send_devise_notification)
          subject
        end
      end

      context 'when the password to change is invalid' do
        let(:updates) { {password: '', password_confirmation: ''} }

        it 'does not send an email' do
          expect(user).not_to receive(:send_devise_notification)
          subject
        end
      end

      context 'when the password and its confirmation are different' do
        let(:updates) { {password: 'password1', password_confirmation: 'another_password'} }

        it 'does not send an email' do
          expect(user).not_to receive(:send_devise_notification)
          subject
        end
      end

      context 'when the password is given without confirmation' do
        let(:updates) { {password: 'new_password'} }

        it 'does not send an email' do
          expect(user).not_to receive(:send_devise_notification)
          subject
        end
      end
    end
  end
end
