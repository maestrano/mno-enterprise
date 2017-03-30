require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::AuditEventsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/organizations/1/audit_events')).to route_to('mno_enterprise/jpi/v1/audit_events#index', organization_id: '1')
    end
  end
end
