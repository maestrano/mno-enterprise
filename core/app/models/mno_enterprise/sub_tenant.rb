module MnoEnterprise
  class SubTenant < BaseResource
    has_many :account_managers, class_name: 'MnoEnterprise::User'
    has_many :clients, class_name: 'MnoEnterprise::Organization'
  end
end
