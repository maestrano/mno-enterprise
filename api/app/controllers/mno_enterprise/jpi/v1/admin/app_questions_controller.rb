module MnoEnterprise
  class Jpi::V1::Admin::AppQuestionsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_questions
    def index
      @app_reviews = MnoEnterprise::AppQuestion
      @app_reviews = @app_reviews.limit(params[:limit]) if params[:limit]
      @app_reviews = @app_reviews.skip(params[:offset]) if params[:offset]
      @app_reviews = @app_reviews.order_by(params[:order_by]) if params[:order_by]
      @app_reviews = @app_reviews.where(params[:where]) if params[:where]
      @app_reviews = @app_reviews.all.fetch
      response.headers['X-Total-Count'] = @app_reviews.metadata[:pagination][:count]
    end
  end
end
