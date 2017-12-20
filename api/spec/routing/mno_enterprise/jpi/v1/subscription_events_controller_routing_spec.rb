require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::SubscriptionEventsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context "Product provisioning is enabled" do
      before(:all) do
        Settings[:dashboard][:marketplace][:provisioning] = true
        Rails.application.reload_routes!
      end

      it 'routes to #index' do
        expect(get('/jpi/v1/organizations/1/subscriptions/xyz/subscription_events')).to route_to("mno_enterprise/jpi/v1/subscription_events#index", organization_id: '1', subscription_id: 'xyz')
      end

      it 'routes to #show' do
        expect(get('/jpi/v1/organizations/1/subscriptions/xyz/subscription_events/abc')).to route_to("mno_enterprise/jpi/v1/subscription_events#show", id: 'abc', organization_id: '1', subscription_id: 'xyz')
      end
    end

    context "Product provisioning is disabled" do
      before(:all) do
        Settings[:dashboard][:marketplace][:provisioning] = false
        Rails.application.reload_routes!
      end

      it 'does not route to #index' do
        expect(get('/jpi/v1/organizations/1/subscription_events')).not_to be_routable
      end

      it 'does not route to #show' do
        expect(get('/jpi/v1/organizations/1/subscription_events/abc')).not_to be_routable
      end
    end
  end
end
