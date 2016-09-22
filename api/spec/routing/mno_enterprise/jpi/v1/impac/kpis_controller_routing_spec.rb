require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::KpisController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/impac/kpis')).to route_to('mno_enterprise/jpi/v1/impac/kpis#index')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/impac/kpis/2')).to route_to('mno_enterprise/jpi/v1/impac/kpis#show', id: '2')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/impac/kpis/2')).to route_to('mno_enterprise/jpi/v1/impac/kpis#update', id: '2')
      expect(patch('/jpi/v1/impac/kpis/2')).to route_to('mno_enterprise/jpi/v1/impac/kpis#update', id: '2')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/impac/kpis/2')).to route_to('mno_enterprise/jpi/v1/impac/kpis#destroy', id: '2')
    end

    it 'routes to #create (dashboard nested)' do
      expect(post('/jpi/v1/impac/dashboards/1/kpis')).to route_to('mno_enterprise/jpi/v1/impac/kpis#create', dashboard_id: '1')
    end
  end
end
