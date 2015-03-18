require 'rails_helper'

module MnoEnterprise
  RSpec.describe Devise::RegistrationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #new' do
      expect(get('/auth/users/sign_up')).to route_to("devise/registrations#new")
    end
    
    it 'routes to #create' do
      expect(post('/auth/users')).to route_to("devise/registrations#create")
    end
  end
end

