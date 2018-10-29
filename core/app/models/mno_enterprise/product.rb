module MnoEnterprise
  class Product < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :nid, type: :string
    property :name, type: :string
    property :active, type: :boolean
    property :product_type, type: :string
    property :logo, type: :string
    property :custom_schema, type: :string
    property :provisioning_url, type: :string
    property :external_id, type: :string
    property :externally_provisioned, type: :boolean
    property :parent_id, type: :string
    property :local, type: :boolean
    property :free_trial_enabled, type: :boolean
    property :free_trial_duration, type: :integer
    property :free_trial_unit, type: :string
    property :single_billing_enabled, type: :boolean
    property :billed_locally, type: :boolean
    property :multi_instantiable, type: :boolean
    property :available_actions

    def to_audit_event
      {
        id: id,
        nid: nid,
        name: name,
        product_type: product_type
      }
    end
  end
end
