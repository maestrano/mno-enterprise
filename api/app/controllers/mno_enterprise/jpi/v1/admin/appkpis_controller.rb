module MnoEnterprise
  class Jpi::V1::Admin::AppkpisController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/appkpis
    def index
        # Index mode
        query = MnoEnterprise::Appkpis.apply_query_params(params)
        @appkpis = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
    end

    # GET /mnoe/jpi/v1/admin/appkpis/1
    def show
      @appkpis = MnoEnterprise::App.find_one(params[:id])
    end
  end
end
