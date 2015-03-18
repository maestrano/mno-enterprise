require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Registration", type: :request do
    
    let(:confirmation_token) { 'wky763pGjtzWR7dP44PD' }
    let(:api_user) { build(:api_user, :unconfirmed, confirmation_token: confirmation_token) }
    let(:api_user_uniq_resp) { build(:api_user_validate_uniqueness) }
    let(:signup_attrs) { { name: "John", surname: "Doe", email: 'john@doecorp.com', password: 'securepassword' } }
    
    before { api_stub_for(MnoEnterprise::User, method: :get, path: '/users/validate_uniqueness', response: api_user_uniq_resp) }
    before { api_stub_for(MnoEnterprise::User, method: :post, path: '/users', response: api_user) }
    before { api_stub_for(MnoEnterprise::User, method: :put, path: '/users/usr-1', response: api_user) }
    
    # Stub call checking if another user already has the confirmation token provided
    # by devise
    before { allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(confirmation_token) }
    before { api_stub_for(MnoEnterprise::User, 
      method: :get, 
      path: '/users', 
      params: { filter: {confirmation_token: confirmation_token }, limit: 1 },
      response: []
    )}
    
    describe 'signup' do  
      describe 'success' do
        it 'signs the user up' do
          post '/mnoe/auth/users', user: signup_attrs
          expect(controller).to be_user_signed_in
          
          user = controller.current_user
          expect(user.id).to eq(api_user[:id])
          expect(user.name).to eq(api_user[:name])
          expect(user.surname).to eq(api_user[:surname])
        end
      end
      
      describe 'failure' do
        let(:api_user_uniq_resp) { build(:api_user_validate_uniqueness, :fail) }
        
        it 'does logs the user in' do
          post '/mnoe/auth/users', user: signup_attrs
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
