module MnoEnterprise
  class Jpi::V1::AppReviewsController < Jpi::V1::BaseResourceController
    before_action :ensure_app_exists
    before_action :find_review, only: [:update, :destroy]

    # GET /mnoe/jpi/v1/marketplace/:id/app_reviews
    def index
      @app_reviews = review_klass.approved
      @app_reviews = @app_reviews.limit(params[:limit]) if params[:limit]
      @app_reviews = @app_reviews.skip(params[:offset]) if params[:offset]
      @app_reviews = @app_reviews.order_by(params[:order_by]) if params[:order_by]
      @app_reviews = @app_reviews.where(params[:where]) if params[:where]

      @app_reviews = scope_app_reviews

      @app_reviews = @app_reviews.all.fetch
      response.headers['X-Total-Count'] = @app_reviews.metadata[:pagination][:count]
    end

    # POST /mnoe/jpi/v1/marketplace/:id/app_reviews/:id
    def show
      @app_review = review_klass.find(params[:review_id])
    end

    # POST /mnoe/jpi/v1/marketplace/:id/app_reviews
    def create
      # TODO: use the has_many associations -> @app.reviews.build
      @app_review = review_klass.new(review_params)
      if @app_review.save
        after_save
        render :show
      else
        render json: @app_review.errors, status: :bad_request
      end
    end

    def update
      if @app_review.update(permitted_params)
        after_save
        render :show
      else
        render json: @app_review.errors, status: :bad_request
      end
    end

    def destroy
      @app_review.destroy
      after_save

      render :show
    end

    private

    # scope the app_reviews for the children controller
    # may be overriden
    def scope_app_reviews
      @app_reviews.where(reviewable_id: current_app.id)
    end

    # perform some additional actions if new review was created
    # may be overriden
    def after_save
      @average_rating = current_app.reload.average_rating
    end

    def current_app
      @app ||= MnoEnterprise::App.find(params[:id])
    end

    def ensure_app_exists
      render_not_found('App') unless current_app.present?
    end

    def find_review
      @app_review = review_klass.find(params[:review_id])
      unless @app_review.user_id == current_user.id
        return render json:{ errors: {message: "Review not found (id=#{params[:review_id]})", code: 404} }, status: :not_found
      end
    end

    def review_klass
      MnoEnterprise::AppReview
    end

    def permitted_params
      params.require(:app_review).permit(:rating, :description, :organization_id)
    end

    def review_params
      permitted_params.merge(app_id: current_app.id, user_id: current_user.id)
    end
  end
end
