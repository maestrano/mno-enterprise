require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::MarketplaceController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/marketplace')).to route_to("mno_enterprise/jpi/v1/marketplace#index")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/marketplace/1')).to route_to("mno_enterprise/jpi/v1/marketplace#show", id: '1')
    end
  end
end

