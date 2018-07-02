FactoryGirl.define do
  factory :product_quote, class: MnoEnterprise::ProductQuote do
    sequence(:id, &:to_s)
    organization_id 1
    quote { { finalQuotedPrice: 20 } }
    custom_schema { {custom: 'schema' } }
    product_id 1
  end
end
