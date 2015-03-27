require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Authentication", type: :request do
    
    let(:api_user) { build(:api_user) }
    #put /users/usr-1 id=usr-1&name=John&remember_created_at=&remember_token=&surname=Doe
    before { api_stub_for(MnoEnterprise::User, method: :put, path: '/users/usr-1', response: api_user) }
    
    describe 'login' do
      describe 'success' do
        before { api_stub_for(MnoEnterprise::User, method: :post, path: '/users/authenticate', response: api_user) }
        
        it 'logs the user in' do
          post '/mnoe/auth/users/sign_in', user: { email: api_user[:email], password: 'securepassword' }
          #puts controller.inspect
          #expect(controller).to be_user_signed_in
          expect(controller.current_user.id).to eq(api_user[:id])
          #expect(controller.current_user.name).to eq(api_user[:name])
        end
      end
      
      describe 'failure' do
        before { api_stub_for(MnoEnterprise::User, method: :post, path: '/users/authenticate', code: 404, response: { errors: "does not exist"}) }
        
        it 'does logs the user in' do
          post '/mnoe/auth/users/sign_in', user: { email: 'john@doecorp.com', password: 'wrongpassword' }
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
