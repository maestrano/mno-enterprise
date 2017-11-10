require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::NotificationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/notifications')).to route_to("mno_enterprise/jpi/v1/admin/notifications#index", format: "json")
    end

    it 'routes to #update' do
      expect(post('/jpi/v1/admin/notifications/notified')).to route_to("mno_enterprise/jpi/v1/admin/notifications#notified", format: "json")
    end
  end
end
