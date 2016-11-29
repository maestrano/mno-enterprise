module MnoEnterprise
  class AppUserRating < BaseResource
    scope :approved, -> { where(status: 'approved') }

    attributes :id, :rating, :description, :created_at, :updated_at, :app_id, :user_id

    belongs_to :user, class_name: 'MnoEnterprise::User'
    belongs_to :app, class_name: 'MnoEnterprise::App'

  end
end
