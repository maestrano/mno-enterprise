module MnoEnterprise
  class Jpi::V1::AppReviewsController < Jpi::V1::BaseResourceController
    # GET /mnoe/jpi/v1/marketplace/:id/app_reviews
    def index
      @app_reviews = MnoEnterprise::AppReview.approved.where(reviewable_id: params[:id])
      @app_reviews = @app_reviews.limit(params[:limit]) if params[:limit]
      @app_reviews = @app_reviews.skip(params[:offset]) if params[:offset]
      @app_reviews = @app_reviews.order_by(params[:order_by]) if params[:order_by]
      @app_reviews = @app_reviews.where(params[:where]) if params[:where]
      @app_reviews = @app_reviews.all.fetch
      response.headers['X-Total-Count'] = @app_reviews.metadata[:pagination][:count]
    end

    # POST /mnoe/jpi/v1/marketplace/:id/app_reviews
    def create
      @app = MnoEnterprise::App.find(params[:id])
      return render json: "could not find App #{params[:id]}", status: :not_found unless @app

      # TODO: use the has_many associations -> @app.reviews.build
      @app_review = MnoEnterprise::AppReview.new(review_params(@app.id))
      if @app_review.save
        @average_rating = @app.reload.average_rating
        render :show
      else
        render json: @app_review.errors, status: :bad_request
      end
    end

    def review_params(app_id)
      params.require(:app_review).permit(:rating, :description, :organization_id)
        .merge(app_id: app_id, user_id: current_user.id)
    end
  end
end
