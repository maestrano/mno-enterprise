module MnoEnterprise
  class Admin::InvoicesController < MnoEnterprise::Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/invoices/201504-NU4
    def show
      @invoice = MnoEnterprise::Invoice.where(slug: params[:id].upcase).reload.first

      respond_to do |format|
        if @invoice
          filename = "Invoice - #{@invoice.slug}.pdf"
          pdf_view = MnoEnterprise::InvoicePdf.new(@invoice).render
          format.html { send_data pdf_view, filename: filename, type: "application/pdf", disposition: 'inline'  }
        else
          format.html { redirect_to root_path, alert: 'Sorry, the page requested could not be displayed' }
        end
      end
    end
  end
end
