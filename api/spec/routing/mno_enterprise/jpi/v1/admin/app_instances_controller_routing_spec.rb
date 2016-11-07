require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AppInstancesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/app_instances/1')).to route_to("mno_enterprise/jpi/v1/admin/app_instances#destroy", id: '1', format: "json" )
    end
  end
end
