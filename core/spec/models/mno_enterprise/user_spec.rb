require 'rails_helper'

module MnoEnterprise
  RSpec.describe User, type: :model do
    describe 'password strength' do
      let(:user) do
        # Initialize this way so the class reload is taken into account (the factory doesnt reload the User class)
        MnoEnterprise::User.new(attributes_for(:user, password: 'password')).tap {|u| u.clear_attribute_changes!}
      end

      context 'without password regex' do
        it 'does not validate the password strength' do
          expect(user).to be_valid
        end
      end

      context 'with password regex' do
        before do
          Devise.password_regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/

          # Reload User class to redefine the validation
          # Removes MnoEnterprise::User from object-space:
          MnoEnterprise.send(:remove_const, :User)
          # Reloads the module (require might also work):
          load 'app/models/mno_enterprise/user.rb'
        end

        it 'validates the password strength' do
          expect(user).to be_invalid
          expect(user.errors[:password].first).to eq('must contains at least one uppercase letter, one lower case letter and a number')
        end

        after do
          # Reset to default
          Devise.password_regex = nil
          MnoEnterprise.send(:remove_const, :User)
          load 'app/models/mno_enterprise/user.rb'
        end
      end
    end

    describe :intercom_user_hash do
      let(:user) { MnoEnterprise::User.new(email: 'admin@example.com') }

      context 'without Intercom' do
        # default
        it { expect(user).not_to respond_to(:intercom_user_hash) }
      end

      context 'with Intercom' do
        before do
          allow(MnoEnterprise).to receive(:intercom_enabled?).and_return(true)
          allow(MnoEnterprise).to receive(:intercom_api_secret).and_return('mysecret')

          # Reload User class to include IntercomUser concern
          MnoEnterprise.send(:remove_const, :User)
          load 'app/models/mno_enterprise/user.rb'
        end

        it 'returns the user intercom hash' do
          expect(user.intercom_user_hash).not_to be_nil
        end

        after do
          # Reset to default
          MnoEnterprise.send(:remove_const, :User)
          load 'app/models/mno_enterprise/user.rb'
        end
      end
    end
  end
end
