module MnoEnterprise
  class Review < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id, type: :string
  end

end
