require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::WidgetsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #create (dashboard nested)' do
      expect(post('/jpi/v1/impac/dashboards/2/widgets')).to route_to('mno_enterprise/jpi/v1/impac/widgets#create', dashboard_id: '2')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/impac/widgets#update', id: '2')
      expect(patch('/jpi/v1/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/impac/widgets#update', id: '2')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/impac/widgets#destroy', id: '2')
    end

    it 'routes to #index' do
      expect(get('/jpi/v1/impac/organizations/1/widgets')).to route_to('mno_enterprise/jpi/v1/impac/widgets#index', organization_id: '1')
    end
  end
end
