require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::SubscriptionsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context 'Product provisioning is enabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {provisioning: true}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/admin/subscriptions')).to route_to('mno_enterprise/jpi/v1/admin/subscriptions#index', format: 'json')
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/admin/organizations/1/subscriptions')).to route_to('mno_enterprise/jpi/v1/admin/subscriptions#index', organization_id: '1', format: 'json')
      end
    end

    context 'Product provisioning is disabled' do
      before(:all) do
        Settings.merge!(dashboard: {marketplace: {provisioning: false}})
        Rails.application.reload_routes!
      end

      it 'does not route to #show' do
        expect(get('/jpi/v1/admin/subscriptions')).not_to be_routable
      end

      it 'does not route to #index' do
        expect(get('/jpi/v1/admin/organizations/1/subscriptions')).not_to be_routable
      end
    end
  end
end
