module MnoEnterprise
  class Subscription < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :status, type: :string
    property :subscription_type, type: :string
    property :start_date, type: :date
    property :end_date, type: :date
    property :max_licenses, type: :integer
    property :available_licenses, type: :integer
    property :external_id, type: :string
    property :custom_data, type: :string

    has_one :product_instance
    has_one :organization
    has_one :user
    has_one :product_contract
    has_one :product_pricing

    def to_audit_event
      {
        id: id,
        status: status,
        organization_id: organization&.id,
        user_id: user&.id
      }
    end
  end
end
