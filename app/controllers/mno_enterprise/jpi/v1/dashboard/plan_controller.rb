class Jpi::V1::Dashboard::PlanController < ApplicationController
  before_filter :set_timestamp
  before_filter :set_new_timestamp
  before_filter :set_app_instance
  before_filter :check_authorization

  def show
    render partial: 'show', locals: { app_instance:@app_instance, show_timestamp:true }
  end

  private
  def set_app_instance
    @app_instance = AppInstance.where(id:params[:id]).where("updated_at > (?)",Time.at(@timestamp)).first
  end

  def set_timestamp
    @timestamp = (params[:timestamp] || 0).to_i
  end

  def set_new_timestamp
    @new_timestamp = Time.now.to_i
  end

  # Check that current_user has update rights on the @app_instance
  def check_authorization
    unless current_user && (!@app_instance || @app_instance && can?(:update,@app_instance))
      redirect_to root_path
    end
  end
end
