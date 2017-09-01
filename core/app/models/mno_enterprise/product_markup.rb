module MnoEnterprise
  class ProductMarkup < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :percentage
    property :organization_name
    property :product_name
    property :organization_id
    property :product_id
  end
end
