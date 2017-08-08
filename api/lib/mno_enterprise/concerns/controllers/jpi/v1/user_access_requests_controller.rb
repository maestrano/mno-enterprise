module MnoEnterprise::Concerns::Controllers::Jpi::V1::UserAccessRequestsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  # GET /mnoe/jpi/v1/user_access_requests
  def index
    @user_access_requests = MnoEnterprise::UserAccessRequest.includes(:requester).where(user_id: current_user.id, status: 'requested').to_a
  end

  # PUT /mnoe/jpi/v1/user_access_requests/:id/deny
  def deny
    return render_not_found('user_access_request') unless user_access_request
    @user_access_request = user_access_request.deny.first
    if @user_access_request.errors.empty?
      @user_access_request = @user_access_request.load_required(:requester)
      MnoEnterprise::EventLogger.info('access_denied', current_user.id, 'Access denied', @user_access_request)
      MnoEnterprise::SystemNotificationMailer.access_denied(user_access_request.id).deliver_later
      render 'show'
    else
      render_bad_request('deny', @user_access_request.errors)
    end
  end

  # PUT /mnoe/jpi/v1/user_access_requests/:id/approve
  def approve
    return render_not_found('user_access_request') unless user_access_request
    @user_access_request = user_access_request.approve.first
    if @user_access_request.errors.empty?
      @user_access_request = @user_access_request.load_required(:requester)
      MnoEnterprise::EventLogger.info('access_approved', current_user.id, 'Access approved', @user_access_request)
      MnoEnterprise::SystemNotificationMailer.access_approved(user_access_request.id).deliver_later
      render 'show'
    else
      render_bad_request('approve', @user_access_request.errors)
    end
  end

  def user_access_request
    @user_access_request ||= MnoEnterprise::UserAccessRequest.find_one(params[:id])
  end
end
