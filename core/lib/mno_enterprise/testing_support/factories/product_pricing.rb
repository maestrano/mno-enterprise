FactoryGirl.define do
  factory :product_pricing, class: MnoEnterprise::ProductPricing do
    sequence(:id, &:to_s)
  end
end
