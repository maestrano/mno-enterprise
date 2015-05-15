require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Authentication", type: :request do
    
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }
    
    describe 'login' do
      subject { post '/mnoe/auth/users/sign_in', user: { email: 'john@doecorp.com', password: 'securepassword' } }
      
      describe 'success' do
        before { api_stub_for(post: '/user_sessions', response: from_api(user)) }
        before { subject }
        
        # Obscure failure happens when running all specs
        # NoMethodError:
        #        undefined method `empty?' for nil:NilClass
        xit 'logs the user in' do
          post '/mnoe/auth/users/sign_in', user: { email: user.email, password: 'securepassword' }
          #puts controller.inspect
          #expect(controller).to be_user_signed_in
          expect(controller.current_user.id).to eq(user.id)
          #expect(controller.current_user.name).to eq(api_user[:name])
        end
      end
      
      describe 'failure' do
        before { api_stub_for(post: '/user_sessions', code: 404, response: { errors: "does not exist"}) }
        before { subject }
        
        it 'does logs the user in' do  
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
