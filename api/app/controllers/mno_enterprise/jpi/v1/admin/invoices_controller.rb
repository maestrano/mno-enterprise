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
  end
end
