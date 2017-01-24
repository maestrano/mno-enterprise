module MnoEnterprise
  # List All Answers
  # MnoEnterprise::AppAnswer.all
  # Create an AppAnswer
  # MnoEnterprise::AppAnswer.create(description: "This is my answer", organization_id: 3, user_id: 9, app_id: 43, question_id: 1)

  # An AppAnswer belong to an AppQuestion
  class AppAnswer < AppReview
    attributes :question_id
  end
end
