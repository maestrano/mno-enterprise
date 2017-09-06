require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AppsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/apps')).to route_to('mno_enterprise/jpi/v1/admin/apps#index', format: 'json')
    end

    it 'routes to #enable' do
      expect(patch('/jpi/v1/admin/apps/1/enable')).to route_to('mno_enterprise/jpi/v1/admin/apps#enable', format: 'json', id: '1')
      expect(patch('/jpi/v1/admin/apps/enable')).to route_to('mno_enterprise/jpi/v1/admin/apps#enable', format: 'json')
    end

    it 'routes to #disable' do
      expect(patch('/jpi/v1/admin/apps/1/disable')).to route_to('mno_enterprise/jpi/v1/admin/apps#disable', format: 'json', id: '1')
    end
  end
end
