module MnoEnterprise
  class Jpi::V1::Admin::AppCommentsController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_comments
    def create
      @app_review = MnoEnterprise::AppComment.create(app_comment_params)

      render :show
    end

    def app_comment_params
      params.require(:app_comment).permit(:description, :feedback_id).merge(user_id: current_user.id)
    end
  end
end
