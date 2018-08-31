module MnoEnterprise::Concerns::Controllers::Jpi::V1::InvoicesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context

  included do
    before_filter :authenticate_user!, only: :show
    before_filter :redirect_to_lounge_if_unconfirmed, only: :show
    before_filter :check_authorization, only: :index
  end

  #==================================================================
  # Instance methods
  #================================================================
  # GET /mnoe/jpi/v1/organizations/:organization_id/invoices
  def index
    authorize! :manage_billing, parent_organization
    query = MnoEnterprise::Invoice.apply_query_params(params, MnoEnterprise::Invoice.where('organization.id': parent_organization.id))

    response.headers['X-Total-Count'] = query.meta.record_count
    @invoices = query.to_a
  end

  # GET /mnoe/jpi/v1/invoices/201504-NU4
  # Invoices endpoint for admins of an organization, rather than admin of a tenant
  def show
    @invoice = MnoEnterprise::Invoice.where(slug: params[:id].upcase).includes(:organization).first
    authorize! :manage_billing, current_user.organizations.find(@invoice.organization_id).first

    respond_to do |format|
      if @invoice
        filename = "Invoice - #{@invoice.slug}.pdf"
        pdf_view = MnoEnterprise::InvoicePdf.new(@invoice).render
        format.html { send_data pdf_view, filename: filename, type: "application/pdf", disposition: 'inline'  }
      else
        format.html { redirect_to root_path, :alert => 'Sorry, the page requested could not be displayed' }
      end
    end
  end
end
