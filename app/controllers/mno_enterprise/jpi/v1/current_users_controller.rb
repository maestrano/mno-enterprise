module MnoEnterprise
  class Jpi::V1::CurrentUsersController < ApplicationController
    respond_to :json

    # GET /jpi/v1/current_user
    def infos
      if @current_user = current_user
        @user = @current_user
        @deletion_request = current_user.deletion_requests.active.first

        # All the organizations related to the user including customer organizations minus the reseller organization
        @organizations = Organization.accessible_by(Ability.new(current_user))
      else
        @user = User.new
        @user.free_trial_end_at = 1.month.from_now
      end
    end
  end
end
