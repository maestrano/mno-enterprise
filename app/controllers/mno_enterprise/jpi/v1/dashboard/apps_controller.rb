class Jpi::V1::Dashboard::AppsController < Jpi::V1::Dashboard::DashboardController

  # GET /jpi/v1/dashboard/organization/1/apps.json?timestamp=151452452345
  def index
    @app_instances = AppInstance.accessible_by(current_ability)
      .where(owner_type: 'Organization',owner_id: @orga.id)
      .active
      .where("updated_at > ?", Time.at(@timestamp))

    render partial: 'index'
  end
end
