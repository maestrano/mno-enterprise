FactoryGirl.define do
  factory :product_markup, class: MnoEnterprise::ProductMarkup do
    sequence(:id, &:to_s)
    percentage 0.12
    product { build(:product) }
    organization { build(:organization) }
  end
end
