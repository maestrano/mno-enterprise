module MnoEnterprise::Concerns::Controllers::Jpi::V1::InvoicesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context

  included do
    before_filter :authenticate_user!
    before_filter :redirect_to_lounge_if_unconfirmed
  end

  #==================================================================
  # Instance methods
  #================================================================

  # GET /mnoe/jpi/v1/invoices/201504-NU4
  # Invoices endpoint for admins of an organization, rather than admin of a tenant
  def show
    @invoice = MnoEnterprise::Invoice.where(slug: params[:id].upcase).includes(:organization).first
    authorize! :manage_billing, current_user.organizations.find(@invoice.organization_id).first

    respond_to do |format|
      if @invoice
        filename = "Invoice - #{@invoice.slug}.pdf"
        pdf_view = MnoEnterprise::InvoicePdf.new(@invoice).render
        format.html { send_data pdf_view, filename: filename, type: "application/pdf", disposition: 'inline' }
      else
        format.html { redirect_to root_path, :alert => 'Sorry, the page requested could not be displayed' }
      end
    end
  end
end
