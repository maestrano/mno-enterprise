module MnoEnterprise
  class Jpi::V1::Admin::InvoicesController < Jpi::V1::Admin::BaseResourceController

    ADJUSTMENT_ATTRIBUTES = [:description, :price_cents]

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # GET /mnoe/jpi/v1/admin/invoices
    def index
      if params[:terms]
        # Search mode
        @invoices = []
        JSON.parse(params[:terms]).map { |t| @invoices = @invoices | invoice_index_query.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @invoices.count
      else
        # Index mode
        query = invoice_index_query(params)
        @invoices = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # GET /mnoe/jpi/v1/admin/invoices/1
    def show
      @invoice = MnoEnterprise::Invoice
        .with_params(_metadata: special_roles_metadata)
        .select(:id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug, :tax_pips_applied,
          :organization, { organizations: [:id, :name] },
          :bills, bills: [:id, :adjustment, :billing_group, :end_user_price_cents, :currency, :description,
            :closed_end_user_price, :closure_exchange_rate])
        .includes(:organization, :bills)
        .find(params[:id]).first
    end

    # PATCH /mnoe/jpi/v1/admin/invoices/1
    def update
      # Fetch or fail
      invoice = MnoEnterprise::Invoice.with_params(_metadata: special_roles_metadata)
                                      .select(:id)
                                      .find(params[:id])
                                      .first
      return render_not_found('Invoice') unless invoice

      # Update invoice. Only 'paid_at' can be edited
      invoice.update!(invoice_params)

      render json: :ok
    end

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # POST /mnoe/jpi/v1/admin/invoices/:id/adjustments
    def create_adjustment
      # Fetch invoice
      invoice = MnoEnterprise::Invoice
        .with_params(_metadata: special_roles_metadata)
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

      bill.save!
      # Refetch invoice totals
      invoice = MnoEnterprise::Invoice.select(:price, :total_due).find(params[:id]).first

      # Render invoice totals
      render json: { id: bill.id, invoice: { price: invoice.price, total_due: invoice.total_due } }
    end

    # NOTE: it would be preferable to use Invoice#price_cents
    # and Invoice#currency rather than Invoice#price
    #
    # DELETE /mnoe/jpi/v1/admin/invoices/:id/adjustments/:bill_id
    def delete_adjustment
      # Check that current user has access to the invoice
      invoice = MnoEnterprise::Invoice.with_params(_metadata: special_roles_metadata).select(:id)
      return render_not_found('Invoice') unless invoice

      # Find adjustment bill
      bill = MnoEnterprise::Bill.select(:id).where(
        'adjustment' => true,
        'invoice.id' => params[:id],
        'id' => params[:bill_id]
      ).first
      return render_not_found('Adjustment', params[:bill_id]) unless bill

      # Delete adjustment. Note that adjustments are hard deleted
      # instead of cancelled.
      bill.destroy!
      # Refetch invoice totals
      invoice = MnoEnterprise::Invoice.select(:price, :total_due).find(params[:id]).first

      # Render invoice totals
      render json: { invoice: { price: invoice.price, total_due: invoice.total_due } }

    end

    # GET /mnoe/jpi/v1/admin/invoices/current_billing_amount
    def current_billing_amount
      current_billing = tenant_reporting.current_billing_amount
      render json: { current_billing_amount: format_money(current_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_invoicing_amount
    def last_invoicing_amount
      tenant_billing = tenant_reporting.last_customers_invoicing_amount
      render json: { last_invoicing_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/outstanding_amount
    def outstanding_amount
      tenant_billing = tenant_reporting.last_customers_outstanding_amount
      render json: { outstanding_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_portfolio_amount
    def last_portfolio_amount
      tenant_billing = tenant_reporting.last_portfolio_amount
      render json: { last_portfolio_amount: format_money(tenant_billing) }
    end

    # GET /mnoe/jpi/v1/admin/invoices/last_commission_amount
    def last_commission_amount
      tenant_billing = tenant_reporting.last_commission_amount
      render json: { last_commission_amount: format_money(tenant_billing) }
    end

    # POST /mnoe/jpi/v1/admin/invoices/1/send_to_customer
    def send_to_customer
      invoice = MnoEnterprise::Invoice
                  .with_params(_metadata: special_roles_metadata)
                  .select(:organization, organizations: [:id])
                  .includes(:organization)
                  .find(params[:id]).first

      render_not_found('invoice') unless invoice

      organization = MnoEnterprise::Organization
                       .select(:orga_relations, orga_relations: [:id, :user_id, :role])
                       .includes(:orga_relations)
                       .find(invoice.organization.id).first

      render_not_found('organization') unless organization

      organization.orga_relations.each do |orga_relation|
        next unless (orga_relation.role == 'Super Admin')
        MnoEnterprise::SystemNotificationMailer.send_invoice(orga_relation.user_id, params[:id]).deliver_later
      end
      render json: { status: :request_sent}

    end

    #==================================================================
    # Private
    #==================================================================
    private

    def tenant_reporting
      @tenant_reporting ||= MnoEnterprise::TenantReporting.with_params(_metadata: special_roles_metadata)
                                                          .find
                                                          .first
    end

    def format_money(money)
      if money
        {amount: money.amount, currency: money.currency_as_string}
      else
        {amount: 'N/A', currency: ''}
      end
    end

    def invoice_params
      params.require(:invoice).permit(:paid_at, :tax_pips_applied)
    end

    def adjustment_params
      params.require(:adjustment).permit(*ADJUSTMENT_ATTRIBUTES)
    end

    def invoice_index_query(query_params = nil)
      rel = MnoEnterprise::Invoice
      rel = rel.apply_query_params(query_params) if query_params
      rel.with_params(_metadata: special_roles_metadata)
         .select(:id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug,
                 :organization, organizations: [:id, :name])
         .includes(:organization)
    end
  end
end
