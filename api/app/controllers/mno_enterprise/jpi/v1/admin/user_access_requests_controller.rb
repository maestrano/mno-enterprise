module MnoEnterprise::Jpi::V1::Admin
  # Manage invitation sending
  class UserAccessRequestsController < BaseResourceController
    def create
      user = MnoEnterprise::User.find_one(params[:user_id])
      return render json: { error: 'Could not find account or user' }, status: :not_found unless user
      user_access_request = MnoEnterprise::UserAccessRequest.new
      user_access_request.relationships.user = user
      user_access_request.relationships.requester = current_user
      user_access_request.save!
      MnoEnterprise::SystemNotificationMailer.request_access(user_access_request.id).deliver_later
      MnoEnterprise::EventLogger.info('access_requested', current_user.id, 'Access requested', user_access_request)
      head :no_content
    end
  end
end
