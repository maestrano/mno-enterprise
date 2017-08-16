module MnoEnterprise
  class Jpi::V1::AppFeedbacksController < Jpi::V1::AppReviewsController

    private

    def permitted_params
      root_params.permit(:rating, :description)
    end

    def review_klass
      MnoEnterprise::Feedback
    end

    def initial_scope
      review_klass.includes(:comments)
    end
  end
end
