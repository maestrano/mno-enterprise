FactoryGirl.define do
  factory :product_contract, class: MnoEnterprise::ProductContract do
    sequence(:id, &:to_s)
  end
end
