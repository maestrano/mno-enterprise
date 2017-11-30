module MnoEnterprise::Concerns::Controllers::Jpi::V1::DeletionRequestsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
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
  #==================================================================
  # POST /deletion_request.json
  def create
    @deletion_request = MnoEnterprise::DeletionRequest.create!(deletable: current_user)
    # TODO: deliver_later => need to use user#id and deletion_request#id
    MnoEnterprise::SystemNotificationMailer.deletion_request_instructions(current_user, @deletion_request).deliver_now
    render json: @deletion_request, status: :created
  end

  # PUT /deletion_request/1/resend.json
  def resend
    @deletion_request = current_user.current_deletion_request
    # Check that the user has a deletion_request in progress
    # and that the token provided (params[:id]) matches the
    # deletion_request token
    if @deletion_request.present? && @deletion_request.token == params[:id]
      MnoEnterprise::SystemNotificationMailer.deletion_request_instructions(current_user, @deletion_request).deliver_now
      render json: @deletion_request
    else
      head :bad_request
    end
  end

  # DELETE /deletion_request/1.json
  def destroy
    @deletion_request = current_user.current_deletion_request

    # Check that the user has a deletion_request in progress
    # and that the token provided (params[:id]) matches the
    # deletion_request token
    if @deletion_request.present? && @deletion_request.token == params[:id]
      @deletion_request.destroy!
      head :no_content
    else
      head :bad_request
    end
  end
end
