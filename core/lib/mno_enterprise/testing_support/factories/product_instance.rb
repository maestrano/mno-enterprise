FactoryGirl.define do
  factory :product_instance, class: MnoEnterprise::ProductInstance do
    sequence(:id, &:to_s)
    product { build(:product) }
  end
end
