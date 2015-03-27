module MnoEnterprise
  class Jpi::V1::UsersController < ApplicationController
    respond_to :json

    # GET /jpi/v1/users/infos.json
    def infos
      if @current_user = current_user
        @user = @current_user
        @administrated_orgas = Organization.accessible_by(Ability.new(current_user)).select { |e| !(e.reseller_entity) }.select do |orga|
          can? :upload, orga
        end
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
