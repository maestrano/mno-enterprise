module MnoEnterprise
  class Jpi::V1::Admin::InvoicesController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:organization, :bills, :'bills.billable']
    ADJUSTMENT_ATTRIBUTES = [:description, :price_cents]

    # NOTE: we should reduce the number of fields being fetched
    #
    # NOTE: not sure that the dependencies are required here. It's only a listing.
    #
    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
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

    # NOTE: we should reduce the number of fields being fetched
    #
    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # GET /mnoe/jpi/v1/admin/invoices/1
    def show
      @invoice = MnoEnterprise::Invoice.find_one(params[:id], *DEPENDENCIES)
    end

    # PATCH /mnoe/jpi/v1/admin/invoices/1
    def update
      # Fetch or fail
      invoice = MnoEnterprise::Invoice.select(:id).find(params[:id]).first
      return render_not_found('Invoice') unless invoice

      # Update invoice. Only 'paid_at' can be edited
      invoice.update(invoice_params)

      render json: :ok
    end

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # POST /mnoe/jpi/v1/admin/invoices/:id/adjustments
    def create_adjustment
      # Fetch invoice
      invoice = MnoEnterprise::Invoice
        .select(:currency, :organization, organizations: [:id])
        .includes(:organization)
        .find(params[:id]).first
      return render_not_found('Invoice') unless invoice

      # Filter attributes and attach invoice currency
      attributes = adjustment_params.merge({ currency: invoice.currency })

      # Create adjustment bill
      bill = MnoEnterprise::Bill.new(attributes)
      bill.relationships.billable = MnoEnterprise::Organization.new(id: invoice.organization.id)
      bill.relationships.invoice = invoice
      bill.save

      # Refetch invoice totals
      invoice = MnoEnterprise::Invoice.select(:price, :total_due).find(params[:id]).first

      # Render invoice totals
      render json: { invoice: { price: invoice.price, total_due: invoice.total_due } }
    end

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # DELETE /mnoe/jpi/v1/admin/invoices/:id/adjustments/:bill_id
    def delete_adjustment
      # Find adjustment bill
      bill = MnoEnterprise::Bill.select(:id).where(
        'billable.type' => 'organizations',
        'invoice.id' => params[:id],
        'id' => params[:bill_id]
      ).first
      return render_not_found('Adjustment', params[:bill_id]) unless bill

      # Delete adjustment. Note that adjustments are hard deleted
      # instead of cancelled.
      bill.destroy

      # Refetch invoice totals
      invoice = MnoEnterprise::Invoice.select(:price, :total_due).find(params[:id]).first

      # Render invoice totals
      render json: { invoice: { price: invoice.price, total_due: invoice.total_due } }
    end

    # GET /mnoe/jpi/v1/admin/invoices/current_billing_amount
    def current_billing_amount
      current_billing = tenant.current_billing_amount
      render json: { current_billing_amount: format_money(current_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_invoicing_amount
    def last_invoicing_amount
      tenant_billing = tenant.last_customers_invoicing_amount
      render json: { last_invoicing_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/outstanding_amount
    def outstanding_amount
      tenant_billing = tenant.last_customers_outstanding_amount
      render json: { outstanding_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_portfolio_amount
    def last_portfolio_amount
      tenant_billing = tenant.last_portfolio_amount
      render json: { last_portfolio_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_commission_amount
    def last_commission_amount
      tenant_billing = tenant.last_commission_amount
      render json: { last_commission_amount: format_money(tenant_billing) }
    end

    #==================================================================
    # Private
    #==================================================================
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

    def adjustment_params
      params.require(:adjustment).permit(*ADJUSTMENT_ATTRIBUTES)
    end
  end
end
