module MnoEnterprise::Jpi::V1::Admin
  # Manage invitation sending
  class AccessRequestsController < BaseResourceController
    def create
      user = MnoEnterprise::User.find_one(params[:user_id])
      return render json: {error: 'Could not find account or user'}, status: :not_found unless user
      user_access_request = MnoEnterprise::UserAccessRequest.new
      user_access_request.relationships.user = user
      user_access_request.relationships.requester = current_user
      user_access_request.save
      # MnoEnterprise::SystemNotificationMailer.access_request(user_access_request.id).deliver_later
      head :no_content
    end
  end
end
