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
  end
end

