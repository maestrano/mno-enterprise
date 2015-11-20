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

    # GET /mnoe/jpi/v1/admin/invoices/current_billing_amount
    def current_billing_amount
      data = Rails.cache.fetch('tenant_admin/current_billing_amount', expires_in: ADMIN_CACHE_DURATION) do
        billing = MnoEnterprise::Organization.all.map(&:current_billing).sum(Money.new(0))
        {current_billing_amount: {amount: billing.amount, currency: billing.currency_as_string}}
      end
      render json: data
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_invoicing_amount
    def last_invoicing_amount
      tenant_billing = MnoEnterprise::Tenant.get('tenant').last_customers_invoicing_amount
      render json: {last_invoicing_amount: {amount: tenant_billing.amount, currency: tenant_billing.currency_as_string}}
    end

    # GET /mnoe/jpi/v1/admin/invoices/outstanding_amount
    def outstanding_amount
      tenant_billing = MnoEnterprise::Tenant.get('tenant').last_customers_outstanding_amount
      render json: {outstanding_amount: {amount: tenant_billing.amount, currency: tenant_billing.currency_as_string}}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_portfolio_amount
    def last_portfolio_amount
      tenant_billing = MnoEnterprise::Tenant.get('tenant').last_portfolio_amount
      render json: {last_portfolio_amount: {amount: tenant_billing.amount, currency: tenant_billing.currency_as_string}}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_commission_amount
    def last_commission_amount
      tenant_billing = MnoEnterprise::Tenant.get('tenant').last_commission_amount
      render json: {last_commission_amount: {amount: tenant_billing.amount, currency: tenant_billing.currency_as_string}}
    end
  end
end
