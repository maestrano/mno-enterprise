module MnoEnterprise
  class SubTenant < BaseResource
    attributes :name, :account_manager_ids, :client_ids

    has_many :account_managers, class_name: 'MnoEnterprise::User'
    has_many :clients, class_name: 'MnoEnterprise::Organization'
  end
end
