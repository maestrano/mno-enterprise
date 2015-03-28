require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Registration", type: :request do
    
    let(:confirmation_token) { 'wky763pGjtzWR7dP44PD' }
    let(:user) { build(:user, :unconfirmed, confirmation_token: confirmation_token) }
    let(:email_uniq_resp) { [] }
    let(:signup_attrs) { { name: "John", surname: "Doe", email: 'john@doecorp.com', password: 'securepassword' } }
    
    # Stub user creation
    before { api_stub_for(MnoEnterprise::User, method: :post, path: '/users', response: from_api(user)) }
    
    # Stub user update
    before { api_stub_for(MnoEnterprise::User, method: :put, path: "/users/#{user.id}", response: from_api(user)) }
    
    # Stub call checking if another user already has the confirmation token provided
    # by devise
    before { allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(confirmation_token) }
    before { api_stub_for(MnoEnterprise::User, 
      method: :get, 
      path: '/users',
      params: { filter: {confirmation_token: confirmation_token }, limit: 1 },
      response: []
    )}
    
    # Stub user email uniqueness check
    before { api_stub_for(MnoEnterprise::User, 
      path: '/users',
      params: { filter: { email: signup_attrs[:email] }, limit: 1 },
      response: email_uniq_resp
    )}
    
    
    
    describe 'signup' do  
      describe 'success' do
        it 'signs the user up' do
          post '/mnoe/auth/users', user: signup_attrs
          expect(controller).to be_user_signed_in
          
          user = controller.current_user
          expect(user.id).to eq(user.id)
          expect(user.name).to eq(user.name)
          expect(user.surname).to eq(user.surname)
        end
      end
      
      describe 'failure' do
        let(:email_uniq_resp) { [from_api(user)] }
        
        it 'does logs the user in' do
          post '/mnoe/auth/users', user: signup_attrs
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
