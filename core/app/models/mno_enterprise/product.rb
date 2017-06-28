module MnoEnterprise
  class Product < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :nid, type: :string
    property :name, type: :string
    property :active, type: :boolean
    property :product_type, type: :string
    property :logo, type: :string
    property :custom_schema_url, type: :string
    property :provisioning_url, type: :string
    property :external_id, type: :string
    property :externally_provisioned, type: :boolean
    property :parent_id, type: :string

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
