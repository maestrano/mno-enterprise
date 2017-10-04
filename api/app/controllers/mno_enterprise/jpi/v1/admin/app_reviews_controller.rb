module MnoEnterprise
  class Jpi::V1::Admin::AppReviewsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_reviews
    def index
      relation = MnoEnterprise::Review.where('reviewer_type': 'OrgaRelation', 'reviewable_type': 'App')
      query = MnoEnterprise::Review.apply_query_params(params, relation)
      @app_reviews = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end

    # GET /mnoe/jpi/v1/admin/app_reviews/1
    def show
      @app_review = MnoEnterprise::Review.find_one(params[:id])
    end

    # PATCH /mnoe/jpi/v1/admin/app_reviews/1
    def update
      @app_review = MnoEnterprise::Review.find_one(params[:id])
      @app_review.update!(app_review_params)
      render :show
    end

    def app_review_params
      params.require(:app_review).permit(:status, :description).merge(user_id: current_user.id)
    end
  end
end
