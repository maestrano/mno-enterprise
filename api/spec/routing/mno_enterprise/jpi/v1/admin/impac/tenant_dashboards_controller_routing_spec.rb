require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::Impac::TenantDashboardsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/impac/tenant_dashboards')).to route_to('mno_enterprise/jpi/v1/admin/impac/tenant_dashboards#index', format: 'json')
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/impac/tenant_dashboards')).to route_to('mno_enterprise/jpi/v1/admin/impac/tenant_dashboards#create', format: 'json')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/impac/tenant_dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/tenant_dashboards#update', id: '2', format: 'json')
      expect(patch('/jpi/v1/admin/impac/tenant_dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/tenant_dashboards#update', id: '2', format: 'json')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/impac/tenant_dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/tenant_dashboards#destroy', id: '2', format: 'json')
    end
  end
end
