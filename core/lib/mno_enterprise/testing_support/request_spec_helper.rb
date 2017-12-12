# Helpers used in Request Specs
module MnoEnterprise::TestingSupport::RequestSpecHelper
  shared_context 'signed in user' do
    # Simulate a user login by login through devise
    def login
      # Stub user manipulation
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))

      # Stub session authentication
      api_stub_for(post: '/user_sessions', code: 200, response: from_api(user))

      # Log in
      post '/mnoe/auth/users/sign_in', user: {email: user.email, password: 'securepassword'}
    end

    let(:user) { FactoryGirl.build(:user, password_valid: true) }
    before { login }
  end
end
