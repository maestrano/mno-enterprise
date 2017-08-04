require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::SubscriptionsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context "Product provisioning is enabled" do
      before(:all) do
        Settings.merge!(dashboard: {provisioning: {enabled: true}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/organizations/1/subscriptions')).to route_to("mno_enterprise/jpi/v1/subscriptions#index", organization_id: '1')
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/organizations/1/subscriptions/abc')).to route_to("mno_enterprise/jpi/v1/subscriptions#show", id: 'abc', organization_id: '1')
      end

      it 'routes to #create' do
        expect(post('/jpi/v1/organizations/1/subscriptions')).to route_to("mno_enterprise/jpi/v1/subscriptions#create", organization_id: '1')
      end

      it 'routes to #update' do
        expect(put('/jpi/v1/organizations/1/subscriptions/abc')).to route_to("mno_enterprise/jpi/v1/subscriptions#update", id: 'abc', organization_id: '1')
      end

      it 'routes to #cancel' do
        expect(post('/jpi/v1/organizations/1/subscriptions/abc/cancel')).to route_to("mno_enterprise/jpi/v1/subscriptions#cancel", id: 'abc', organization_id: '1')
      end
    end

    context "Product provisioning is disabled" do
      before(:all) do
        Settings.merge!(dashboard: {provisioning: {enabled: false}})
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/organizations/1/subscriptions')).not_to be_routable
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/organizations/1/subscriptions/abc')).not_to be_routable
      end

      it 'routes to #create' do
        expect(post('/jpi/v1/organizations/1/subscriptions')).not_to be_routable
      end

      it 'routes to #update' do
        expect(put('/jpi/v1/organizations/1/subscriptions/abc')).not_to be_routable
      end
    end
  end
end
