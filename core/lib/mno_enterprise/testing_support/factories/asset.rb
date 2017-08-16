FactoryGirl.define do
  factory :asset, class: MnoEnterprise::Asset do
    sequence(:id, &:to_s)
  end
end
