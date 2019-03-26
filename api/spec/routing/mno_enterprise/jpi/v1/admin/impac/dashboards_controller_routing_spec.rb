require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::Impac::DashboardsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/impac/dashboards')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#index', format: 'json')
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/impac/dashboards')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#create', format: 'json')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#update', id: '2', format: 'json')
      expect(patch('/jpi/v1/admin/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#update', id: '2', format: 'json')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#destroy', id: '2', format: 'json')
    end

    it 'routes to #copy' do
      expect(post('/jpi/v1/admin/impac/dashboards/2/copy')).to route_to('mno_enterprise/jpi/v1/admin/impac/dashboards#copy', id: '2', format: 'json')
    end
  end
end
