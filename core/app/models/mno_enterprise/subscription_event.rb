module MnoEnterprise
  class SubscriptionEvent < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :uid, type: :string
    property :status, type: :string
    property :event_type, type: :string
    property :message, type: :string
    property :provisioning_data

    has_one :subscription

    def to_audit_event
      event = {id: id, status: status}
      event[:subscription_id] = relationships.subscription&.dig('data', 'id') if relationships.respond_to?(:subscription)
      event
    end
  end
end
