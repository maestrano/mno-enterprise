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
    property :product_instance_id, type: :string
    property :pricing_id, type: :string
    property :contract_id, type: :string
    property :organization_id, type: :string
    property :user_id, type: :string

    def to_audit_event
      {
        id: id,
        status: status
      }
    end
  end
end
