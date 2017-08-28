module MnoEnterprise
  class Jpi::V1::Admin::AppMetricsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/app_metrics
    def index
        # Index mode
        query = MnoEnterprise::AppMetrics.apply_query_params(params)
        @app_metrics = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
    end

    # GET /mnoe/jpi/v1/admin/app_metrics/1
    def show
      @app_metrics = MnoEnterprise::App.find_one(params[:id])
    end
  end
end
