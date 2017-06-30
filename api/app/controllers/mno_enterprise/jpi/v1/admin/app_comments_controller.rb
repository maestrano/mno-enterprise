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

    # PATCH /mnoe/jpi/v1/admin/app_comments/1
    def update
      @app_review = MnoEnterprise::AppComment.find(params[:id])
      @app_review.update(app_comment_update_params)
      render :show
    end

    private

    def app_comment_update_params
      params.require(:app_comment).permit(:description)
    end

    def app_comment_params
      # for an admin, the organization does not matter
      organization_id = current_user.organizations.first.id
      params.require(:app_comment).permit(:description)
        .merge(user_id: current_user.id, feedback_id: parent.id, organization_id: organization_id, app_id: parent.app_id)
    end

    def parent
      @parent ||= MnoEnterprise::AppFeedback.find(params[:feedback_id])
    end
  end
end
