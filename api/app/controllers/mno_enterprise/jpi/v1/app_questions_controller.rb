module MnoEnterprise
  class Jpi::V1::AppQuestionsController < Jpi::V1::AppReviewsController

    private

    def after_save
      #do nothing because questions doesn't affect on app rating
    end

    def permitted_params
      params.require(:app_question).permit(:description)
    end

    def review_klass
      MnoEnterprise::Question
    end

    def initial_scope
      review_klass.includes(:answers)
    end
  end
end
