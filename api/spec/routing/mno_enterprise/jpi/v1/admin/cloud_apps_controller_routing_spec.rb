require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::CloudAppsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/admin/cloud_apps')).to route_to('mno_enterprise/jpi/v1/admin/cloud_apps#index', format: 'json')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/cloud_apps/1')).to route_to('mno_enterprise/jpi/v1/admin/cloud_apps#update', id: '1', format: 'json')
    end

    it 'routes to #regenerate_api_key' do
      expect(put('/jpi/v1/admin/cloud_apps/1/regenerate_api_key')).to route_to('mno_enterprise/jpi/v1/admin/cloud_apps#regenerate_api_key', id: '1', format: 'json')
    end

    it 'routes to #refresh_metadata' do
      expect(put('/jpi/v1/admin/cloud_apps/1/refresh_metadata')).to route_to('mno_enterprise/jpi/v1/admin/cloud_apps#refresh_metadata', id: '1', format: 'json')
    end
        
  end
end
