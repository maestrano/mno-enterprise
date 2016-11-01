require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::AppInstancesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/organizations/1/app_instances')).to route_to("mno_enterprise/jpi/v1/app_instances#index", organization_id: '1')
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/organizations/1/app_instances')).to route_to("mno_enterprise/jpi/v1/app_instances#create", organization_id: '1' )
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/app_instances/1')).to route_to("mno_enterprise/jpi/v1/app_instances#destroy", id: '1' )
    end
  end
end
