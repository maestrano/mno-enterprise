module MnoEnterprise
  # Create an AppQuestion
  # MnoEnterprise::AppQuestion.create(description: "This is my question", organization_id: 3, user_id: 9, app_id: 43)
  class AppQuestion < AppReview
    # belongs_to :app

    # scope :search, ->(search) { where("description.like" => "%#{search}%") }
  end
end
