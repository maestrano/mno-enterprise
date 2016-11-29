require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Authentication", type: :request do

    let(:user) { build(:user, password_valid: true) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }

    # Stub session authentication
    let(:session_resp_code) { 200 }
    let(:session_resp) { from_api(user) }
    before { api_stub_for(post: '/user_sessions',
                          code: -> { session_resp_code },
                          response: -> { session_resp }
    ) }

    describe 'login' do
      subject { post '/mnoe/auth/users/sign_in', user: {email: user.email, password: 'securepassword'} }

      describe 'success' do
        before { subject }

        it 'logs the user in' do
          expect(controller).to be_user_signed_in
          expect(controller.current_user.id).to eq(user.id)
          expect(controller.current_user.name).to eq(user.name)
        end
      end

      describe 'failure' do
        let(:session_resp_code) { 404 }
        let(:session_resp) { {errors: "does not exist"} }
        before { subject }

        it 'does logs the user in' do
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
