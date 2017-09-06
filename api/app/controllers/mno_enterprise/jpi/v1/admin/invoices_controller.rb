module MnoEnterprise
  class Jpi::V1::Admin::InvoicesController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:organization, :bills, :'bills.billable']
    ADJUSTMENT_ATTRIBUTES = [:billable_description, :price_cents, :id]  

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
      @invoice = MnoEnterprise::Invoice.find_one(params[:id], *DEPENDENCIES)
      invoice_adjustments if params[:invoice][:adjustments]
      @invoice.update(invoice_params)
      render json: :ok
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

    def invoice_adjustments
      bills = @invoice.bills
      params[:invoice][:adjustments].each do |adjustment|
        attributes = adjustment.permit(*ADJUSTMENT_ATTRIBUTES).merge(bill_attributes)
        # create a new bill only if the param adjustment has no :id
        MnoEnterprise::Bill.create(attributes) unless adjustment.key?(:id)
        # update the bill if fields have changed
        update_bill(adjustment) if adjustment.key?(:id) && bills.any? { |b| b.id == adjustment[:id] && (b.billable != adjustment[:billable_description] || b.price_cents != adjustment[:price_cents])}
      end
      # delete the bill if does not exist in the params
      params[:invoice][:adjustments].each do |adjustment|
        bills.find { |a| if adjustment.key?(:id) then adjustment[:id] == a.id end }
        delete_bill(adjustment)
      end
    end

    def update_bill(adjustment)
      bill = MnoEnterprise::Bill.find_one(adjustment[:id])
      adjustment.delete(:id)
      bill.update(adjustment)
    end

    def delete_bill(bill)
      bill = MnoEnterprise::Bill.find_one(bill[:id])
      bill.destroy
    end

    def bill_attributes
      {
        invoice_id: @invoice.id,
        billable_type: 'Organization',
        billable_id: params[:invoice][:organization][:id],
        price_per_unit: "0",
        billing_type: 'monthly',
        units: "0",
        currency: @invoice.price.currency
      }
    end

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
