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
    @deletion_request = MnoEnterprise::DeletionRequest.new(:deletable => current_user)

    if @deletion_request.save
      # AccountMailer.delay.deletion_request_instructions(current_user,{deletion_request:@deletion_request})
      # SystemNotificationMailer.organization_invite(@org_invite).deliver_now
      # deliver_later
      # SystemNotificationMailer.deletion_request_instructions(current_user,{deletion_request:@deletion_request}).deliver_now
      render json: @deletion_request, status: :created
    else
      render json: @deletion_request.errors, status: :unprocessable_entity
    end

  end
end
