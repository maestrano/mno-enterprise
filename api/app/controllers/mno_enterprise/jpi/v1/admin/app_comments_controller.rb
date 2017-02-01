module MnoEnterprise
  class Jpi::V1::Admin::AppCommentsController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_comments
    def create
      @app_review = MnoEnterprise::AppComment.new(app_comment_params)

      if @app_review.save
        render :show
      else
        render json: @app_review.errors, status: :bad_request
      end
    end

    private

    def app_comment_params
      params.require(:app_comment).permit(:description)
        .merge(user_id: current_user.id, feedback_id: parent.id, organization_id: parent.organization_id, app_id: parent.app_id)
    end

    def parent
      @parent ||= MnoEnterprise::AppFeedback.find(params[:feedback_id])
    end
  end
end
