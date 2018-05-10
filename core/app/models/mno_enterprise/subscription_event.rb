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

    custom_endpoint :approve, on: :member, request_method: :post
    custom_endpoint :reject, on: :member, request_method: :post

    def approve!(args)
      process_custom_result(approve(args))
    end

    def reject!(args)
      process_custom_result(reject(args))
    end

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
