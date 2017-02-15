module MnoEnterprise
  class Jpi::V1::Admin::AppReviewsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_reviews
    def index
      @app_reviews = MnoEnterprise::AppReview
      @app_reviews = @app_reviews.limit(params[:limit]) if params[:limit]
      @app_reviews = @app_reviews.skip(params[:offset]) if params[:offset]
      @app_reviews = @app_reviews.order_by(params[:order_by]) if params[:order_by]
      @app_reviews = @app_reviews.where(params[:where]) if params[:where]
      @app_reviews = @app_reviews.all.fetch
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
      params.require(:app_review).permit(:status, :description).merge(user_id: current_user.id)
    end
  end
end
