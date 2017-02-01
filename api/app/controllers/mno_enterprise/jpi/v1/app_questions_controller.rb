module MnoEnterprise
  class Jpi::V1::AppQuestionsController < Jpi::V1::AppReviewsController

    private

    def scope_app_reviews
      collection = @app_reviews.where(reviewable_id: current_app.id)
      collection = collection.search(params[:search]) if params[:search].present?

      collection
    end

    def after_save
      #do nothing because questions doesn't affect on app rating
    end

    def permitted_params
      params.require(:app_question).permit(:description, :organization_id)
    end

    def review_klass
      MnoEnterprise::AppQuestion
    end
  end
end
