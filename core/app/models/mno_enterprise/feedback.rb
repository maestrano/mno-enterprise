module MnoEnterprise
  # Create an AppFeedback
  # MnoEnterprise::AppFeedback.create(description: "description", reviewer_id: 3, reviewer_type: 'OrgaRelation', user_id: 9, reviewable_id: 43, reviewable_type: 'App')
  class Feedback < Review
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id, type: :string
  end
end
