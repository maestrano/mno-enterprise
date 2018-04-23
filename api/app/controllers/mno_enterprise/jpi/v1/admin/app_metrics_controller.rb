module MnoEnterprise
  class Jpi::V1::Admin::AppMetricsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/app_metrics
    def index
      staff_role = current_user.admin_role == 'staff'
      org_ids = current_user.client_ids
      @app_metrics = []

      if params[:terms]
        # Search mode
        unless staff_role
          JSON.parse(params[:terms]).map { |t| @app_metrics = @app_metrics | MnoEnterprise::AppMetrics.where(Hash[*t]) }
        else
          JSON.parse(params[:terms]).map { |t| @app_metrics = @app_metrics | MnoEnterprise::AppMetrics.where(organization_ids: org_ids).where(Hash[*t]) } if org_ids.present?
        end

      else
        # Index mode
        if !staff_role || org_ids.present?
          query = MnoEnterprise::AppMetrics.apply_query_params(params)
          query = query.where(organization_ids: org_ids) if org_ids.present?
          @app_metrics = query.to_a
        end
      end
      response.headers['X-Total-Count'] = @app_metrics.count
    end

    # GET /mnoe/jpi/v1/admin/app_metrics/1
    def show
      @app_metrics = MnoEnterprise::App.find_one(params[:id])
    end
  end
end
