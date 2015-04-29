require 'rails_helper'

module MnoEnterprise
  RSpec.describe Devise::ConfirmationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #show' do
      expect(get('/auth/users/confirmation?confirmation_token=bla')).to route_to("mno_enterprise/auth/confirmations#show", confirmation_token: 'bla')
    end
    
    it 'routes to #finalize' do
      expect(post('/auth/users/confirmation/finalize')).to route_to("mno_enterprise/auth/confirmations#finalize")
    end
    
    it 'routes to #lounge' do
      expect(get('/auth/users/confirmation/lounge')).to route_to("mno_enterprise/auth/confirmations#lounge")
    end
  end
end

