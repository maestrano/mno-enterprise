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
      if relationships.respond_to?(:subscription)
        subscription = relationships.subscription
        event[:subscription_id] = subscription&.dig('data', 'id')
        event[:organization_id] = subscription.relationships.organization&.dig('data', 'id') if subscription.relationships.respond_to?(:subscription)
      end
      event
    end
  end
end
