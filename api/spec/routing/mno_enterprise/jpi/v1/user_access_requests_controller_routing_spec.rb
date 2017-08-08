require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::UserAccessRequestsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/user_access_requests')).to route_to('mno_enterprise/jpi/v1/user_access_requests#index')
    end

    it 'routes to #deny' do
      expect(put('/jpi/v1/user_access_requests/1/deny')).to route_to('mno_enterprise/jpi/v1/user_access_requests#deny', id: '1')
    end

    it 'routes to #approve' do
      expect(put('/jpi/v1/user_access_requests/1/approve')).to route_to('mno_enterprise/jpi/v1/user_access_requests#approve', id: '1')
    end

  end
end

