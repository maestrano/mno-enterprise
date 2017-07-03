module MnoEnterprise
  class Jpi::V1::AppReviewsController < Jpi::V1::BaseResourceController
    before_action :ensure_app_exists
    before_action :ensure_orga_relation_exists, only: [:create]

    before_action :find_review, only: [:update, :destroy]

    # GET /mnoe/jpi/v1/marketplace/:id/app_reviews
    def index
      relation = initial_scope.where(reviewer_type: 'OrgaRelation', reviewable_type: 'App', status: 'approved', reviewable_id: current_app.id)
      query = MnoEnterprise::BaseResource.apply_query_params(params, relation)
      @app_reviews = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end

    # POST /mnoe/jpi/v1/marketplace/:id/app_reviews/:id
    def show
      @app_review = review_klass.find_one(params[:review_id], :versions)
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
      @app_review = nil
      render :show
    end

    private

    # perform some additional actions if new review was created
    # may be overriden
    def after_save
      @average_rating = current_app.reload.average_rating
    end

    def current_app
      @app ||= MnoEnterprise::App.find_one(params[:id])
    end

    def orga_relation
      @orga_relation ||= MnoEnterprise::OrgaRelation.where(organization_id: organization_id, user_id: current_user.id).first
    end

    def ensure_app_exists
      render_not_found('App') unless current_app.present?
    end

    def ensure_orga_relation_exists
      render_not_found('OrgaRelation', "organization_id: #{organization_id}, user_id: #{current_user.id}") unless orga_relation.present?
    end

    def find_review
      @app_review = review_klass.find_one(params[:review_id])
      unless @app_review.user_id == current_user.id
        return render json:{ errors: {message: "Review not found (id=#{params[:review_id]})", code: 404} }, status: :not_found
      end
    end

    def review_klass
      Review
    end

    def initial_scope
      review_klass
    end

    def root_params
      symbol = self.class.name.demodulize.chomp('Controller').underscore.singularize.to_sym
      params.require(symbol)
    end

    def organization_id
      root_params.require(:organization_id)
    end

    def permitted_params
      root_params.permit(:rating, :description)
    end

    def review_params
      permitted_params.merge(reviewable_id: current_app.id, reviewable_type: 'App', reviewer_id: orga_relation.id, reviewer_type: 'OrgaRelation')
    end
  end
end
