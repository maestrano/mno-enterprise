module MnoEnterprise
  # List All Answers
  # MnoEnterprise::Answer.all
  # Create an AppAnswer
  # MnoEnterprise::Answer.create(description: "This is my answer", reviewer_id: 3, reviewer_type: 'OrgaRelation', user_id: 9, reviewable_id: 43, reviewable_type: 'App', parent_id: 1)

  # An Answer belong to a Question
  class Answer < Review
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id, type: :string
  end
end
