module MnoEnterprise
  class ProductMarkup < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :percentage
  end
end
