module MnoEnterprise
  class Jpi::V1::Admin::TenantInvoicesController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/tenant_invoices
    def index
      @tenant_invoices = MnoEnterprise::TenantInvoice.all
      @unpaid = @tenant_invoices.select {|tenant_invoices| tenant_invoices.paid_at == nil }
    end

    # GET /mnoe/jpi/v1/admin/tenant_invoices/1
    def show
      @tenant_invoice = MnoEnterprise::TenantInvoice.find(params[:id])
    end
  end
end
