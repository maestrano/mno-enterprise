module MnoEnterprise
  class Jpi::V1::Admin::AppAnswersController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_answers
    def create
      @app_review = MnoEnterprise::AppAnswer.create(app_answer_params)

      render :show
    end

    def app_answer_params
      params.require(:app_answer).permit(:description, :question_id).merge(user_id: current_user.id)
    end
  end
end
