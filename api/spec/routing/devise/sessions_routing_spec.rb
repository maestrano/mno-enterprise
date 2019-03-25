require 'rails_helper'

module MnoEnterprise
  RSpec.describe Devise::SessionsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #new' do
      expect(get('/auth/users/sign_in')).to route_to("mno_enterprise/auth/sessions#new")
    end
    
    it 'routes to #create' do
      expect(post('/auth/users/sign_in')).to route_to("mno_enterprise/auth/sessions#create")
    end
    
    it 'routes to #destroy' do
      expect(delete('/auth/users/sign_out')).to route_to("mno_enterprise/auth/sessions#destroy")
    end

    describe 'route to verify_otp' do
      it "doesn't route to #verify_otp when 2fa isn't enabled" do
        expect(post('/auth/users/sessions/verify_otp'))
          .to_not route_to('mno_enterprise/auth/sessions#verify_otp')
      end
      
      it 'routes to #verify_otp when 2fa enabled for admins' do
        Settings.authentication.two_factor.admin_enabled = true
        Rails.application.reload_routes!
        expect(post('/auth/users/sessions/verify_otp'))
          .to route_to('mno_enterprise/auth/sessions#verify_otp')
      end

      it 'routes to #verify_otp when 2fa enabled for users' do
        Settings.authentication.two_factor.users_enabled = true
        Rails.application.reload_routes!
        expect(post('/auth/users/sessions/verify_otp'))
          .to route_to('mno_enterprise/auth/sessions#verify_otp')
      end
    end
  end
end
