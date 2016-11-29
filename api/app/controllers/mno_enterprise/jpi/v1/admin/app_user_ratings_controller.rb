module MnoEnterprise
  class Jpi::V1::Admin::AppUserRatingsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_user_ratings
    def index
      # Index mode
      res = MnoEnterprise::AppUserRating
      res.limit(params[:limit]) if params[:limit]
      res.skip(params[:offset]) if params[:offset]
      res.order_by(params[:order_by]) if params[:order_by]
      res.where(params[:where]) if params[:where]
      @app_user_ratings = res.all.fetch
      response.headers['X-Total-Count'] = @app_user_ratings.metadata[:pagination][:count]
    end

    # GET /mnoe/jpi/v1/admin/app_user_ratings/1
    def show
      @app_user_rating = MnoEnterprise::AppUserRating.find(params[:id])
    end


    # PATCH /mnoe/jpi/v1/admin/app_user_ratings/1
    def update
      @app_user_rating = MnoEnterprise::AppUserRating.find(params[:id])
      @app_user_rating.update(app_user_rating_params)
      render :show
    end

    def app_user_rating_params
      params.require(:app_user_rating).permit(:status)
    end

  end
end
