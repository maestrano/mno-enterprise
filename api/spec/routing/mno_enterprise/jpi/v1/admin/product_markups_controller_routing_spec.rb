require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::ProductMarkupsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    [:index, :show, :destroy, :update, :create]

    context 'Product Markup is enabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {product_markup: true}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/admin/product_markups')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#index', format: 'json')
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/admin/product_markups/1')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#show', id: '1', format: 'json')
      end

      it 'routes to #create' do
        expect(post('/jpi/v1/admin/product_markups')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#create', format: 'json')
      end

      it 'routes to #update' do
        expect(put('/jpi/v1/admin/product_markups/1')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#update', id: '1', format: 'json')
        expect(patch('/jpi/v1/admin/product_markups/1')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#update', id: '1', format: 'json')
      end

      it 'routes to #destroy' do
        expect(delete('/jpi/v1/admin/product_markups/1')).to route_to('mno_enterprise/jpi/v1/admin/product_markups#destroy', id: '1', format: 'json')
      end
    end

    context 'Product Markup is disabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {product_markup: false}})
        Rails.application.reload_routes!
      end

      it 'loads regular routes' do
        expect(get('/ping')).to route_to('mno_enterprise/status#ping')
      end

      it 'does not routes to #index' do
        expect(get('/jpi/v1/admin/product_markups')).not_to be_routable
      end

      it 'does not routes to #show' do
        expect(get('/jpi/v1/admin/product_markups/1')).not_to be_routable
      end

      it 'does not routes to #create' do
        expect(post('/jpi/v1/admin/product_markups')).not_to be_routable
      end

      it 'does not routes to #update' do
        expect(put('/jpi/v1/admin/product_markups/1')).not_to be_routable
        expect(patch('/jpi/v1/admin/product_markups/1')).not_to be_routable
      end

      it 'does not routes to #destroy' do
        expect(delete('/jpi/v1/admin/product_markups/1')).not_to be_routable
      end
    end
  end
end
