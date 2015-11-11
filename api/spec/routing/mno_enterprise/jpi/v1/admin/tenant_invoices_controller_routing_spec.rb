require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::TenantInvoicesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/tenant_invoices')).to route_to("mno_enterprise/jpi/v1/admin/tenant_invoices#index", format: "json")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/tenant_invoices/1')).to route_to("mno_enterprise/jpi/v1/admin/tenant_invoices#show", format: "json", id: '1')
    end
  end
end

