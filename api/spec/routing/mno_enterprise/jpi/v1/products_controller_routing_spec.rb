require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::ProductsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/products')).to route_to("mno_enterprise/jpi/v1/products#index")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/products/1')).to route_to("mno_enterprise/jpi/v1/products#show", id: '1')
    end
  end
end
