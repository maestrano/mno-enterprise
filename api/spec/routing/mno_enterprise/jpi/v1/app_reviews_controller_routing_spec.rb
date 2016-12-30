require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::AppReviewsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/marketplace/1/app_reviews')).to route_to("mno_enterprise/jpi/v1/app_reviews#index", id: '1')
    end
    it 'routes to #create' do
      expect(post('/jpi/v1/marketplace/1/app_reviews')).to route_to("mno_enterprise/jpi/v1/app_reviews#create", id: '1')
    end
  end
end

