module MnoEnterprise
  # Create an AppFeedback
  # MnoEnterprise::AppFeedback.create(description: "description", organization_id: 3, user_id: 9, app_id: 43, rating: 5)
  class AppFeedback < AppReview
    belongs_to :app

    scope :approved, -> { where(status: 'approved') }
  end
end
