require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Authentication", :type => :request do
    
    let(:api_user) { build(:api_user) }
    
    describe 'login' do
      
      
      describe 'success' do
        before { stub_api_for(MnoEnterprise::User, method: :post, path: '/users/authenticate', response: api_user) }
        
        it 'logs the user in' do
          post '/mnoe/auth/users/sign_in', user: { email: 'john@doecorp.com', password: 'securepassword' }
          expect(controller).to be_user_signed_in
          expect(controller.current_user.id).to eq(api_user[:id])
          expect(controller.current_user.first_name).to eq(api_user[:first_name])
        end
      end
      
      describe 'failure' do
        before { stub_api_for(MnoEnterprise::User, method: :post, path: '/users/authenticate', code: 404, response: { errors: "does not exist"}) }
        
        it 'does logs the user in' do
          post '/mnoe/auth/users/sign_in', user: { email: 'john@doecorp.com', password: 'wrongpassword' }
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
    
  end
end
