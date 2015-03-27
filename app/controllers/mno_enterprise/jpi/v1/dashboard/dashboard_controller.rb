class Jpi::V1::Dashboard::DashboardController < ApplicationController
  before_filter :check_authorization
  before_filter :set_orga
  before_filter :set_timestamp
  before_filter :set_new_timestamp
  
  private

  def set_timestamp
    @timestamp = (params[:timestamp] || 0).to_i
  end

  def set_new_timestamp
    @new_timestamp = Time.now.to_i
  end

  def set_orga
    @orga = Organization.find_by_id(params[:organization_id])
    @organization = @orga
  end

  # Check that current_user is a member of the organization
  def check_authorization
    if params[:organization_id] && current_user
      orga = Organization.find_by_id(params[:organization_id])
      return true if orga && current_user.role(orga)
    end
    render json: "Unauthorized", status: :unauthorized
  end
end
