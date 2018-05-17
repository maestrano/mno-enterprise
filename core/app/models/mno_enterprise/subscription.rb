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
    property :available_actions

    has_one :product
    has_one :product_instance
    has_one :organization
    has_one :user
    has_one :product_contract
    has_one :product_pricing

    custom_endpoint :modify, on: :member, request_method: :post
    custom_endpoint :change, on: :member, request_method: :post
    custom_endpoint :suspend, on: :member, request_method: :post
    custom_endpoint :renew, on: :member, request_method: :post
    custom_endpoint :reactivate, on: :member, request_method: :post
    custom_endpoint :cancel, on: :member, request_method: :post
    custom_endpoint :abandon, on: :member, request_method: :post
    custom_endpoint :cancel_staged, on: :collection, request_method: :post
    custom_endpoint :submit_staged, on: :collection, request_method: :post

    def to_audit_event
      event = {id: id, status: status}
      event[:organization_id] = relationships.organization&.dig('data', 'id') if relationships.respond_to?(:organization)
      event[:user_id] = relationships.user&.dig('data', 'id') if relationships.respond_to?(:user)
      event
    end

    def process_update_request!(subscription, edit_action)
      # Dynamically call the #mno_hub endpoint corresponding with #edit_action specified by the user.
      self.send("#{edit_action}!", subscription)
    end

    def process_staged_update_request!(subscription, edit_action)
      case edit_action
      when 'cancel'
        abandon!
      else
        process_update_request!(subscription, edit_action)
      end
    end

    def modify!(args)
      process_custom_result(modify(args))
    end

    def change!(args)
      process_custom_result(change(args))
    end

    def suspend!(args)
      process_custom_result(suspend(args))
    end

    def renew!(args)
      process_custom_result(renew(args))
    end

    def reactivate!(args)
      process_custom_result(reactivate(args))
    end

    def cancel!(args)
      process_custom_result(cancel(args))
    end

    def abandon!
      process_custom_result(abandon)
    end
  end
end
