module MnoEnterprise
  class Jpi::V1::Admin::AppAnswersController < Jpi::V1::Admin::BaseResourceController

    # POST /mnoe/jpi/v1/admin/app_answers
    def create
      @app_review = MnoEnterprise::Answer.new(app_answer_params)
      @app_review.save!
      render :show
    end

    def app_answer_params
      # for an admin, the organization does not matter
      orga_relation = MnoEnterprise::OrgaRelation.where('user.id': current_user.id).first
      params.require(:app_answer).permit(:description)
        .merge(reviewer_id: orga_relation.id, reviewer_type: 'OrgaRelation',
               parent_id: parent.id, reviewable_id: parent.reviewable_id, reviewable_type: 'App')
    end

    def parent
      @parent ||= MnoEnterprise::Question.find_one(params[:question_id])
    end
  end
end
