module MnoEnterprise
  class SystemEvent < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :event, type: :string
    property :from
    property :to
    property :resource_type, type: :string
    property :resource_id, type: :string
  end
end
