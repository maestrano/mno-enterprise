require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::ProductsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context "Product provisioning is enabled" do
      before(:all) do
        Settings.merge!(dashboard: {provisioning: {enabled: true}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/products')).to route_to("mno_enterprise/jpi/v1/products#index")
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/products/1')).to route_to("mno_enterprise/jpi/v1/products#show", id: '1')
      end
    end

    context "Product provisioning is disabled" do
      before(:all) do
        Settings.merge!(dashboard: {provisioning: {enabled: false}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/products')).not_to be_routable
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/products/1')).not_to be_routable
      end
    end
  end
end
