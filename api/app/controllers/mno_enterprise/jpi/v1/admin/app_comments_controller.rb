module MnoEnterprise
  class Jpi::V1::Admin::AppCommentsController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_comments
    def create
      @app_review = MnoEnterprise::Comment.new(app_comment_params)

      @app_review.save!
      render :show
    end

    private

    def app_comment_params
      # for an admin, the organization does not matter
      orga_relation = current_user.orga_relations.first
      params.require(:app_comment).permit(:description)
        .merge(reviewer_id: orga_relation.id, reviewer_type: 'OrgaRelation',
               parent_id: parent.id, reviewable_id: parent.reviewable_id, reviewable_type: 'App')
    end

    def parent
      @parent ||= MnoEnterprise::Feedback.find_one(params[:feedback_id])
    end
  end
end
