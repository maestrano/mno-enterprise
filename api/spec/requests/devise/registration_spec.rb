require 'rails_helper'

module MnoEnterprise
  RSpec.describe "Remote Registration", type: :request do
    
    let(:confirmation_token) { 'wky763pGjtzWR7dP44PD' }
    let(:user) { build(:user, :unconfirmed, confirmation_token: confirmation_token) }
    let(:email_uniq_resp) { [] }
    let(:signup_attrs) { { name: "John", surname: "Doe", email: 'john@doecorp.com', password: 'securepassword' } }
    
    # Stub user calls
    before { api_stub_for(post: '/users', response: from_api(user)) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }
    
    # Stub user retrieval using confirmation token
    before { api_stub_for(
      get:'/users',
      params: { filter: { confirmation_token: '**' }, limit: 1 },
      response: from_api([])
    )}
    
    # Stub user email uniqueness check
    before { api_stub_for( 
      get: '/users',
      params: { filter: { email: '**' }, limit: 1 },
      response: -> { from_api(email_uniq_resp) }
    )}
    
    # Stub org_invites retrieval
    before { api_stub_for(get: '/org_invites', response: from_api([])) }
    
    
    describe 'signup' do
      subject { post '/mnoe/auth/users', user: signup_attrs }
      
      describe 'success' do
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
        let(:email_uniq_resp) { [from_api(user)] }
        before { subject }
        
        it 'does not log the user in' do
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
