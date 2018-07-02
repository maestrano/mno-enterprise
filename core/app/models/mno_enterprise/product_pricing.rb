module MnoEnterprise
  class ProductPricing < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :name
    property :description
    property :position
    property :free
    property :pricing_type
    property :license_based
    property :free_trial_enabled
    property :free_trial_duration
    property :free_trial_unit
    property :per_duration
    property :per_unit
    property :prices
    property :external_id
    property :product_id
    property :quote_based

    def to_audit_event
      {
        id: id,
        name: name
      }
    end
  end
end
