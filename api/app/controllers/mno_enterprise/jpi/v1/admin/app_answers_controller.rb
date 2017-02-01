module MnoEnterprise
  class Jpi::V1::Admin::AppAnswersController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_answers
    def create
      @app_review = MnoEnterprise::AppAnswer.new(app_answer_params)

      if @app_review.save
        render :show
      else
        render json: @app_review.errors, status: :bad_request
      end
    end

    def app_answer_params
      # for an admin, the organization does not matter
      organization_id = current_user.organizations.first.id
      params.require(:app_answer).permit(:description)
        .merge(user_id: current_user.id, question_id: parent.id, organization_id: organization_id, app_id: parent.app_id)
    end

    def parent
      @parent ||= MnoEnterprise::AppQuestion.find(params[:question_id])
    end
  end
end
