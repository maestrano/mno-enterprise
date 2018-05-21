require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Registration", type: :request do

    let(:confirmation_token) { 'wky763pGjtzWR7dP44PD' }
    let(:user) { build(:user, :unconfirmed, confirmation_token: confirmation_token) }
    let(:email_uniq_resp) { [] }
    let(:signup_attrs) { {name: 'John', surname: 'Doe', email: 'john@doecorp.com', password: 'securepassword'} }
    let(:tenant) { build(:tenant) }

    # Stub user calls
    before {
      stub_api_v2(:get, '/tenant', tenant)
      stub_api_v2(:post, '/users', user)
      stub_user(user)
      stub_api_v2(:patch, "/users/#{user.id}", user)
      stub_api_v2(:get, '/orga_invites', [], [], {filter: {user_email: signup_attrs[:email]}})
      stub_api_v2(:get, '/users', email_uniq_resp, [], {filter: {email: signup_attrs[:email]}, page: {number: 1, size: 1}})
      allow(Devise.token_generator).to receive(:generate).and_return(['ABCD1234', nil])
    }

    describe 'signup' do
      subject { post '/mnoe/auth/users', user: signup_attrs }

      describe 'success' do
        before { stub_audit_events }
        before { subject }

        it 'signs the user up' do
          expect(controller).to be_user_signed_in
          curr_user = controller.current_user
          expect(curr_user.id).to eq(user.id)
          expect(curr_user.name).to eq(user.name)
          expect(curr_user.surname).to eq(user.surname)
        end

        it 'redirects to the confirmation lounge' do
          expect(response).to redirect_to('/mnoe/auth/users/confirmation/lounge')
        end
      end

      describe 'failure' do
        let(:email_uniq_resp) { [user] }
        before { subject }

        it 'does not log the user in' do
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
