module MnoEnterprise
  class Subscription < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :billed_locally, type: :boolean
    property :externally_provisioned, type: :boolean
    property :local_product, type: :boolean
    property :status, type: :string
    property :subscription_type, type: :string
    property :start_date, type: :date
    property :end_date, type: :date
    property :max_licenses, type: :integer
    property :available_licenses, type: :integer
    property :external_id, type: :string
    property :custom_data
    property :provisioning_data

    has_one :product
    has_one :product_instance
    has_one :organization
    has_one :user
    has_one :product_contract
    has_one :product_pricing

    custom_endpoint :cancel, on: :member, request_method: :post
    custom_endpoint :approve, on: :member, request_method: :post
    custom_endpoint :fulfill, on: :member, request_method: :post
    custom_endpoint :modify, on: :member, request_method: :post
    custom_endpoint :enable, on: :member, request_method: :post
    custom_endpoint :suspend, on: :member, request_method: :post

    def to_audit_event
      event = {id: id, status: status}
      event[:organization_id] = relationships.organization&.dig('data', 'id') if relationships.respond_to?(:organization)
      event[:user_id] = relationships.user&.dig('data', 'id') if relationships.respond_to?(:user)
      event
    end

    def fulfill!
      process_custom_result(fulfill)
    end

    def modify!(args)
      process_custom_result(modify(args))
    end

    def approve!
      process_custom_result(approve)
    end

    def cancel!
      process_custom_result(cancel)
    end
  end
end
