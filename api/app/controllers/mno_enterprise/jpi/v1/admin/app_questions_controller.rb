module MnoEnterprise
  class Jpi::V1::Admin::AppQuestionsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/app_questions
    def index
      relation = MnoEnterprise::Question.includes(:answers).where('reviewer_type': 'OrgaRelation', 'reviewable_type': 'App')
      query = MnoEnterprise::Review.apply_query_params(params, relation)
      @app_reviews = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end
  end
end
