require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::UserAccessRequestsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/users/42/user_access_requests')).to route_to('mno_enterprise/jpi/v1/admin/user_access_requests#create', format: 'json', user_id: '42')
    end
  end
end
