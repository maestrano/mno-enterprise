require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::ProductsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context 'Local products are enabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {local_products: true}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/admin/products')).to route_to('mno_enterprise/jpi/v1/admin/products#index', format: 'json')
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/admin/products/1')).to route_to('mno_enterprise/jpi/v1/admin/products#show', id: '1', format: 'json')
      end
    end

    context 'Local products are disabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {local_products: false}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/admin/products')).not_to be_routable
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/admin/products/1')).not_to be_routable
      end
    end
  end
end
