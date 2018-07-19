module MnoEnterprise
  class Admin::InvoicesController < MnoEnterprise::Jpi::V1::Admin::BaseResourceController
    skip_before_filter :block_support_users, only: :show

    # GET /mnoe/invoices/201504-NU4
    def show
      @invoice = MnoEnterprise::Invoice.includes(:organization).where(slug: params[:id].upcase).first
      # Authorize resource, as support members may not have access.
      authorize_support
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

    private

    def authorize_support
      authorize!(:read, @invoice) if current_user.support?
    end
  end
end
