module MnoEnterprise
  class Jpi::V1::AppAnswersController < Jpi::V1::AppReviewsController

    private

    def after_save
      #do nothing because answers doesn't affect on app rating
    end

    def review_klass
      MnoEnterprise::Answer
    end

    def initial_scope
      review_klass.where(parent_id: params[:parent_id])
    end

    def permitted_params
      root_params.permit(:description, :parent_id)
    end
  end
end
