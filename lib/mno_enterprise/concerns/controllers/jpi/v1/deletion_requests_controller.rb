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
    @deletion_request = MnoEnterprise::DeletionRequest.new(user_id: current_user.id)

    if @deletion_request.save
      # TODO: deliver_later => need to use user#id and deletion_request#id
      MnoEnterprise::SystemNotificationMailer.deletion_request_instructions(current_user, @deletion_request).deliver_now
      render json: @deletion_request, status: :created
    else
      render json: @deletion_request.errors, status: :unprocessable_entity
    end

  end
end
