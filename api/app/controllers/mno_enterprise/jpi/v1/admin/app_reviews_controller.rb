module MnoEnterprise
  class Jpi::V1::Admin::AppReviewsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_reviews
    def index
      # Index mode
      res = MnoEnterprise::AppReview
      res.limit(params[:limit]) if params[:limit]
      res.skip(params[:offset]) if params[:offset]
      res.order_by(params[:order_by]) if params[:order_by]
      res.where(params[:where]) if params[:where]
      @app_reviews= res.all.fetch
      response.headers['X-Total-Count'] = @app_reviews.metadata[:pagination][:count]
    end

    # GET /mnoe/jpi/v1/admin/app_reviews/1
    def show
      @app_review = MnoEnterprise::AppReview.find(params[:id])
    end


    # PATCH /mnoe/jpi/v1/admin/app_reviews/1
    def update
      @app_review = MnoEnterprise::AppReview.find(params[:id])
      @app_review.update(app_review_params)
      render :show
    end

    def app_review_params
      params.require(:app_review).permit(:status)
    end

  end
end
