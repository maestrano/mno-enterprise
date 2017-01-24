module MnoEnterprise
  class Jpi::V1::AppCommentsController < Jpi::V1::AppReviewsController

    private

    def scope_app_reviews
      @app_reviews.where(feedback_id: params[:feedback_id])
    end

    def after_create
      #do nothing because comments doesn't affect on app rating
    end

    def review_klass
      MnoEnterprise::AppComment
    end

    def permitted_params
      params.require(:app_comment).permit(:rating, :description, :organization_id, :feedback_id)
    end
  end
end
