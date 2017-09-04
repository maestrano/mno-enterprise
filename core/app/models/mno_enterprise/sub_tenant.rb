module MnoEnterprise
  class SubTenant < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :name
    property :account_manager_ids
    property :client_ids
  end
end
