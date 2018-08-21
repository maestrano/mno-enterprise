require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::QuotesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    context "Product provisioning is enabled" do
      before(:all) do
        Settings.dashboard.marketplace.provisioning = true
        Rails.application.reload_routes!
      end

      it 'routes to #create' do
        expect(post('/jpi/v1/admin/organizations/1/quotes')).to route_to("mno_enterprise/jpi/v1/admin/quotes#create", format: 'json', organization_id: '1')
      end
    end

    context "Product provisioning is disabled" do
      before(:all) do
        Settings.dashboard.marketplace.provisioning = false
        Rails.application.reload_routes!
      end

      it 'does not route to #create' do
        expect(get('/jpi/v1/admin/organizations/1/quotes')).not_to be_routable
      end
    end
  end
end
