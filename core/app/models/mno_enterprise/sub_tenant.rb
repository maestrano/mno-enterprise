module MnoEnterprise
  class SubTenant < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :name

    custom_endpoint :update_clients, on: :member, request_method: :patch
    custom_endpoint :update_account_managers, on: :member, request_method: :patch

    def update_clients!(input)
      result = self.update_clients(input)
      process_custom_result(result)
    end

    def update_account_managers!(input)
      result = self.update_account_managers(input)
      process_custom_result(result)
    end
  end
end
