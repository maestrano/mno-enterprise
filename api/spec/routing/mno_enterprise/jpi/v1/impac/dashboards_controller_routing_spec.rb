require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::DashboardsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/impac/dashboards')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#index')
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/impac/dashboards')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#create')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#show', id: '2')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#update', id: '2')
      expect(patch('/jpi/v1/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#update', id: '2')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/impac/dashboards/2')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#destroy', id: '2')
    end

    it 'routes to #copy' do
      expect(post('/jpi/v1/impac/dashboards/2/copy')).to route_to('mno_enterprise/jpi/v1/impac/dashboards#copy', id: '2')
    end
  end
end
