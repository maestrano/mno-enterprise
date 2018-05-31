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
      if subscription = self.subscription
        event[:subscription_id] = subscription.id
        event[:organization_id] = subscription.organization_id 
      end
      event
    end
  end
end
