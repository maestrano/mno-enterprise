class Jpi::V1::Dashboard::User::AppInstancesController < ApplicationController
  before_filter :check_authorization
  before_filter :set_timestamp
  before_filter :set_timestamp

  # GET /jpi/v1/dashboard/user/app_instances?timestamp=0
  def index
    @app_instances = []
    # Add app_instances owner by the organizations where current_user is a member
    current_user.organizations.each do |orga|
      @app_instances = orga.app_instances.where("updated_at > (?)",Time.at(@timestamp))
    end
    render partial: 'index'
  end

  # GET /jpi/v1/dashboard/user/app_instances/1
  def show
    if @app_instance = AppInstance.find_by_id(params[:id])
      @app_instance = nil unless can? :read, @app_instance
    end
    render partial: 'show'
  end

  private

  def check_authorization
    render json: 'User not logged in', status: :unauthorized unless current_user
  end

  def set_timestamp
    @timestamp = (params[:timestamp] || 0).to_i
    @new_timestamp = Time.now
  end
end
