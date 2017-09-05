module MnoEnterprise
  class Jpi::V1::Admin::InvoicesController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:organization, :bills, :'bills.billable']

    # GET /mnoe/jpi/v1/admin/invoices
    def index
      if params[:terms]
        # Search mode
        @invoices = []
        JSON.parse(params[:terms]).map { |t| @invoices = @invoices | MnoEnterprise::Invoice.includes(DEPENDENCIES).where(Hash[*t]) }
        response.headers['X-Total-Count'] = @invoices.count
      else
        # Index mode
        query = MnoEnterprise::Invoice.apply_query_params(params).includes(DEPENDENCIES)
        @invoices = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/invoices/1
    def show
      @invoice = MnoEnterprise::Invoice.find_one(params[:id], *DEPENDENCIES)
    end

    # PATCH /mnoe/jpi/v1/admin/invoices/1
    def update
      @invoice = MnoEnterprise::Invoice.find_one(params[:id])
      @invoice.update(invoice_params)
      render :show
    end

    # GET /mnoe/jpi/v1/admin/invoices/current_billing_amount
    def current_billing_amount
      current_billing = tenant.current_billing_amount
      render json: {current_billing_amount: format_money(current_billing)}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_invoicing_amount
    def last_invoicing_amount
      tenant_billing = tenant.last_customers_invoicing_amount
      render json: {last_invoicing_amount: format_money(tenant_billing)}
    end

    # GET /mnoe/jpi/v1/admin/invoices/outstanding_amount
    def outstanding_amount
      tenant_billing = tenant.last_customers_outstanding_amount
      render json: {outstanding_amount: format_money(tenant_billing)}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_portfolio_amount
    def last_portfolio_amount
      tenant_billing = tenant.last_portfolio_amount
      render json: {last_portfolio_amount: format_money(tenant_billing)}
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_commission_amount
    def last_commission_amount
      tenant_billing = tenant.last_commission_amount
      render json: {last_commission_amount: format_money(tenant_billing)}
    end

    private

    def tenant
      @tenant ||= MnoEnterprise::TenantReporting.show
    end

    def format_money(money)
      if money
        {amount: money.amount, currency: money.currency_as_string}
      else
        {amount: 'N/A', currency: ''}
      end
    end

    def invoice_params
      params.require(:invoice).permit(:paid_at)
    end
  end
end
