module MnoEnterprise
  class Jpi::V1::Admin::InvoicesController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/invoices
    def index
      @invoices = MnoEnterprise::Invoice.all
    end

    # GET /mnoe/jpi/v1/admin/invoices/1
    def show
      @invoice = MnoEnterprise::Invoice.find(params[:id])
    end

    # GET /mnoe/jpi/v1/admin/invoices/current_billing
    def current_billing_amount
      billing = MnoEnterprise::Organization.all.map(&:current_billing).sum
      render json: {current_billing_amount: {amount: billing.amount, currency: billing.currency_as_string}}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_invoicing_amount
    def last_invoicing_amount
      org_invoice = MnoEnterprise::Organization.all.map(&:last_invoice)
      invoices_sum = org_invoice.map(&:price).compact.sum
      render json: {last_invoicing_amount: {amount: invoices_sum.amount, currency: invoices_sum.currency_as_string}}
    end

    # GET /mnoe/jpi/v1/admin/invoices/outstanding_amount
    def outstanding_amount
      org_invoice = MnoEnterprise::Organization.all.map(&:last_invoice)
      not_paid = org_invoice.select {|invoice| invoice.ended_at == nil }
      # binding.pry
      invoices_sum = not_paid.map(&:price).compact.sum
      render json: {outstanding_amount: {amount: invoices_sum.amount, currency: invoices_sum.currency_as_string}}
    end
  end
end
