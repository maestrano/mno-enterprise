FactoryGirl.define do
  factory :category, class: MnoEnterprise::Asset do
    sequence(:id, &:to_s)
  end
end
