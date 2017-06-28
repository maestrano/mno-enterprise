FactoryGirl.define do
  factory :product_category, class: MnoEnterprise::ProductCategory do
    product { build(:product) }
    category { build(:category) }
  end
end
