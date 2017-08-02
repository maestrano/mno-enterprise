module MnoEnterprise
  class UserAccessRequest < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :requester_id, type: :string
    property :user_id, type: :string

    has_one :user
    has_one :requester

  end
end
