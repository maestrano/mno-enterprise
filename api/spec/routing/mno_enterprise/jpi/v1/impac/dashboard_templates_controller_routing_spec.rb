require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::DashboardTemplatesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/impac/dashboard_templates')).to route_to('mno_enterprise/jpi/v1/impac/dashboard_templates#index')
    end
  end
end
