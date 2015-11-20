require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::InvoicesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/invoices')).to route_to("mno_enterprise/jpi/v1/admin/invoices#index", format: "json")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/invoices/1')).to route_to("mno_enterprise/jpi/v1/admin/invoices#show", format: "json", id: '1')
    end

    it 'routes to #current_billing_amount' do
      expect(get('/jpi/v1/admin/invoices/current_billing_amount')).to route_to("mno_enterprise/jpi/v1/admin/invoices#current_billing_amount", format: "json")
    end

    it 'routes to #last_invoicing_amount' do
      expect(get('/jpi/v1/admin/invoices/last_invoicing_amount')).to route_to("mno_enterprise/jpi/v1/admin/invoices#last_invoicing_amount", format: "json")
    end

    it 'routes to #outstanding_amount' do
      expect(get('/jpi/v1/admin/invoices/outstanding_amount')).to route_to("mno_enterprise/jpi/v1/admin/invoices#outstanding_amount", format: "json")
    end

    it 'routes to #last_portfolio_amount' do
      expect(get('/jpi/v1/admin/invoices/last_portfolio_amount')).to route_to('mno_enterprise/jpi/v1/admin/invoices#last_portfolio_amount', format: 'json')
    end

    it 'routes to #last_commission_amount' do
      expect(get('/jpi/v1/admin/invoices/last_commission_amount')).to route_to('mno_enterprise/jpi/v1/admin/invoices#last_commission_amount', format: 'json')
    end

  end
end

