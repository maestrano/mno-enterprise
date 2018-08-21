module MnoEnterprise
  class SubscriptionEvent < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :uid, type: :string
    property :status, type: :string
    property :event_type, type: :string
    property :message, type: :string
    property :provisioning_data
    property :subscription_details

    has_one :subscription
    has_one :product_pricing

    custom_endpoint :approve, on: :member, request_method: :post
    custom_endpoint :reject, on: :member, request_method: :post

    def approve!(args)
      process_custom_result(approve(args))
    end

    def reject!(args)
      process_custom_result(reject(args))
    end

    def to_audit_event
      event = self.attributes.slice(:id, :status)

      record = if loaded?(:subscription) && subscription.loaded?(:product) && subscription.loaded?(:product_pricing)
                 self
               else
                 load_required(:subscription, 'subscription.product', 'subscription.product_pricing')
               end

      event.merge!(
        subscription_id: record.subscription.id,
        organization_id: record.subscription.organization_id,
        product_name: record.subscription.product.name,
        product_pricing_name: record.subscription.product_pricing&.name || 'N/A'
      )

      event
    end
  end
end
