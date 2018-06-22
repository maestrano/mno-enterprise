module MnoEnterprise
  class ProductQuote < BaseResource
    property :id
    property :organization_id
    property :product_id
    property :quote
    property :custom_schema
    property :selected_currency

    def self.fetch_quote!(form_data)
      create(form_data)
    end
  end
end
