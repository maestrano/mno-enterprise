module MnoEnterprise
  class Quote < BaseResource
    property :id
    property :organization_id
    property :product_id
    property :quote
    property :custom_schema

    def self.fetch_quote!(form_data)
      create(form_data)
    end
  end
end
