require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AppsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/apps')).to route_to("mno_enterprise/jpi/v1/admin/apps#index", format: "json")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/apps/1')).to route_to("mno_enterprise/jpi/v1/admin/apps#show", format: "json", id: '1')
    end

    it 'routes to #apps' do
      expect(get('/jpi/v1/admin/apps/kpi')).to route_to("mno_enterprise/jpi/v1/admin/apps#kpi", format: 'json')
    end
  end
end
