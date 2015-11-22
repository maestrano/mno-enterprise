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

  end
end
