module MnoEnterprise
  class Jpi::V1::AppAnswersController < Jpi::V1::AppReviewsController

    private

    def scope_app_reviews
      @app_reviews.where(question_id: params[:question_id])
    end

    def after_save
      #do nothing because answers doesn't affect on app rating
    end

    def review_klass
      MnoEnterprise::AppAnswer
    end

    def permitted_params
      params.require(:app_answer).permit(:rating, :description, :organization_id, :question_id)
    end
  end
end
