require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AppMetricsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/app_metrics')).to route_to('mno_enterprise/jpi/v1/admin/app_metrics#index', format: 'json')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/app_metrics/1')).to route_to('mno_enterprise/jpi/v1/admin/app_metrics#show', format: 'json', id: '1')
    end
  end
end
