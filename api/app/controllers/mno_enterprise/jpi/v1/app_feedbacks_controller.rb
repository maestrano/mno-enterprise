module MnoEnterprise
  class Jpi::V1::AppFeedbacksController < Jpi::V1::AppReviewsController

    private

    def permitted_params
      params.require(:app_feedback).permit(:rating, :description, :organization_id)
    end

    def review_klass
      MnoEnterprise::AppFeedback
    end
  end
end
