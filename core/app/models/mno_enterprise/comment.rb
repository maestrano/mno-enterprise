module MnoEnterprise

  # Create an AppComment
  # MnoEnterprise::AppComment.create(description: "description", reviewer_id: 3, reviewer_type: 'OrgaRelation', user_id: 9, reviewable_id: 43, reviewable_type: 'App', parent_id: 1)
  class Comment < Review
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id, type: :string
  end
end
