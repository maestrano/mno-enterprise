FactoryGirl.define do
  factory :category, class: MnoEnterprise::Category do
    sequence(:id, &:to_s)
  end
end
