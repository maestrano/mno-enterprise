# TODO: extract the request check to filter or block?
module MnoEnterprise::Concerns::Controllers::DeletionRequestsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user!
    before_filter :redirect_to_lounge_if_unconfirmed
    before_filter :set_meta

    def set_meta
      @meta[:title] = "Account Termination"
      @meta[:description] = "Account Termination"
    end
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #================================================================
  # GET /deletion_requests/1
  def show
    # authorize! :manage_billing, current_user.organizations.find(@invoice.organization_id)
    @deletion_request = current_user.deletion_request

    respond_to do |format|
      # Check that the user has a deletion_request in progress
      # and that the token provided (params[:id]) matches the
      # deletion_request token
      if @deletion_request.present? && @deletion_request.token == params[:id]

        # Contextual assignments
        if ['account_frozen', 'account_checked_out'].include?(@deletion_request.status)
          # @final_invoices = current_user.final_invoices
          @final_invoices = []
        end

        format.html
        format.json { render json: @deletion_request }
      else
        format.html { redirect_to root_path, alert: 'This deletion request is invalid or expired' }
        format.json { head :bad_request }
      end
    end
  end

  # PATCH /deletion_requests/1/freeze_account
  def freeze_account
    @deletion_request = current_user.deletion_request

    respond_to do |format|
      # Check that the user has a deletion_request in progress
      # and that the token provided (params[:id]) matches the
      # deletion_request token
      if @deletion_request.present? && @deletion_request.token == params[:id]
        # Check that the deletion_request has the right status
        if @deletion_request.status == 'pending'
          @deletion_request.freeze_account!
          format.html { redirect_to @deletion_request, notice: "Your account has been frozen" }
        else
          format.html { redirect_to @deletion_request, alert: "Invalid action" }
        end
      else
        format.html { redirect_to root_path, alert: "This deletion request is invalid or expired" }
        format.json { head :bad_request }
      end
    end
  end

  # PATCH /deletion_requests/1/checkout
  def checkout
    @deletion_request = current_user.deletion_request

    respond_to do |format|
      # Check that the user has a deletion_request in progress
      # and that the token provided (params[:id]) matches the
      # deletion_request token
      if @deletion_request.present? && @deletion_request.token == params[:id]
        # Check that the deletion_request has the right status
        if @deletion_request.status == 'account_frozen'
          # TODO:
          #   Attempt to update the credit cards first
          #   Finally Perform the checkout
          @deletion_request.status = 'account_checked_out'
          @deletion_request.save
          format.html { redirect_to @deletion_request, notice: "Checkout has been performed successfully" }
        else
          format.html { redirect_to @deletion_request, alert: "Invalid action" }
        end
      else
        format.html { redirect_to root_path, alert: "This deletion request is invalid or expired" }
      end
    end
  end

end
