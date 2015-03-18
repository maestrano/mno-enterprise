require 'rails_helper'

module MnoEnterprise
  RSpec.describe Devise::PasswordsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #new' do
      expect(get('/auth/users/password/new')).to route_to("devise/passwords#new")
    end
    
    it 'routes to #edit' do
      expect(get('/auth/users/password/edit')).to route_to("devise/passwords#edit")
    end
    
    it 'routes to #update' do
      expect(put('/auth/users/password')).to route_to("devise/passwords#update")
    end
    
    it 'routes to #create' do
      expect(post('/auth/users/password')).to route_to("devise/passwords#create")
    end
  end
end

