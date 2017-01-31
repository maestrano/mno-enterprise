module MnoEnterprise

  # Create an AppComment
  # MnoEnterprise::AppComment.create(description: "description", organization_id: 3, user_id: 9, app_id: 43, feedback_id: 1)
  class AppComment < AppReview
    attributes :feeback_id

    belongs_to :feedback, class_name: 'AppFeedback', foreign_key: :feedback_id
  end
end
