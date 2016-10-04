require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::AlertsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/impac/alerts')).to route_to('mno_enterprise/jpi/v1/impac/alerts#index')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/impac/alerts/2')).to route_to('mno_enterprise/jpi/v1/impac/alerts#update', id: '2')
      expect(patch('/jpi/v1/impac/alerts/2')).to route_to('mno_enterprise/jpi/v1/impac/alerts#update', id: '2')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/impac/alerts/2')).to route_to('mno_enterprise/jpi/v1/impac/alerts#destroy', id: '2')
    end
  
    it 'routes to #create (kpi nested)' do
      expect(post('/jpi/v1/impac/kpis/2/alerts')).to route_to('mno_enterprise/jpi/v1/impac/alerts#create', kpi_id: '2')
    end
  end
end
