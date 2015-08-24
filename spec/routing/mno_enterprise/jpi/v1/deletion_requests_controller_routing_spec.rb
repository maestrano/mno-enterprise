require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::DeletionRequestsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #show' do
      expect(get('/jpi/v1/deletion_requests/1')).to route_to("mno_enterprise/jpi/v1/deletion_requests#show", id: "1")
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/deletion_requests')).to route_to('mno_enterprise/jpi/v1/deletion_requests#create')
    end

    it 'routes to #resend'

    it 'routes to #destroy'
  end
end

