require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AuditEventsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/audit_events')).to route_to('mno_enterprise/jpi/v1/admin/audit_events#index', format: "json")
    end
  end
end
