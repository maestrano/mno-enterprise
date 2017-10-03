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
    @user_access_requests = MnoEnterprise::UserAccessRequest.active_requested(current_user.id)
  end

  # GET /mnoe/jpi/v1/last_access_request
  def last_access_request
    @user_access_request = MnoEnterprise::UserAccessRequest.last_access_request(current_user.id)
    render 'show'
  end

  # POST /mnoe/jpi/v1/user_access_requests
  def create
    MnoEnterprise::UserAccessRequest.notify_pending_requests(current_user, params.require(:access_duration))
    @user_access_request = MnoEnterprise::UserAccessRequest.new(create_params)
    @user_access_request.relationships.user = current_user
    @user_access_request.save
    MnoEnterprise::EventLogger.info('access_authorized', current_user.id, 'Authorize Access', user_access_request)
    @user_access_request = @user_access_request.load_required(:requester)
    render 'show'
  end

  # PUT /mnoe/jpi/v1/user_access_requests/:id/deny
  def deny
    return render_not_found('user_access_request') unless user_access_request
    result = user_access_request.deny
    if result.errors.empty?
      @user_access_request = @user_access_request.load_required(:requester)
      MnoEnterprise::EventLogger.info('access_denied', current_user.id, 'Access denied', @user_access_request)
      MnoEnterprise::SystemNotificationMailer.access_denied(user_access_request.id).deliver_later
      render 'show'
    else
      render_bad_request('deny', result.errors.full_messages)
    end
  end

  # PUT /mnoe/jpi/v1/user_access_requests/:id/approve
  def approve
    return render_not_found('user_access_request') unless user_access_request
    result = user_access_request.approve!()
    if result.errors.empty?
      MnoEnterprise::EventLogger.info('access_approved', current_user.id, 'Access approved', @user_access_request)
      MnoEnterprise::SystemNotificationMailer.access_approved(user_access_request.id).deliver_later
      render 'show'
    else
      render_bad_request('approve', result.errors.full_messages)
    end
  end

  # PUT /mnoe/jpi/v1/user_access_requests/:id/revoke
  def revoke
    return render_not_found('user_access_request') unless user_access_request
    result = user_access_request.revoke
    if result.errors.empty?
      @user_access_request = @user_access_request.load_required(:requester)
      MnoEnterprise::EventLogger.info('access_revoked', current_user.id, 'Access revoked', @user_access_request)
      render 'show'
    else
      render_bad_request('revoke', result.errors.full_messages)
    end
  end

  def user_access_request
    @user_access_request ||= MnoEnterprise::UserAccessRequest.find_one(params[:id])
  end

  def create_params
    # Access request created by the user, and therefore pre-approved
    create_params = { status: 'approved' }
    access_duration = params.require(:access_duration)
    create_params[:expiration_date] = MnoEnterprise::UserAccessRequest::EXPIRATION_TIMEOUT.from_now unless access_duration == 'UNTIL_REVOKED'
    create_params
  end
end
