require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::NotificationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/organizations/1/notifications')).to route_to("mno_enterprise/jpi/v1/notifications#index", organization_id: '1')
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/organizations/1/notifications')).to route_to("mno_enterprise/jpi/v1/notifications#update", organization_id: '1')
    end
  end
end
