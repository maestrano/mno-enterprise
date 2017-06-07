require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::DashboardTemplatesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/dashboard_templates')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#index', format: 'json')
    end
    it 'routes to #create' do
      expect(post('/jpi/v1/admin/dashboard_templates')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#create', format: 'json')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/dashboard_templates/2')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#show', id: '2', format: 'json')
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/admin/dashboard_templates/2')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#update', id: '2', format: 'json')
      expect(patch('/jpi/v1/admin/dashboard_templates/2')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#update', id: '2', format: 'json')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/dashboard_templates/2')).to route_to('mno_enterprise/jpi/v1/admin/dashboard_templates#destroy', id: '2', format: 'json')
    end
  end
end
