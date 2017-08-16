FactoryGirl.define do
  factory :value, class: MnoEnterprise::Value do
    sequence(:id, &:to_s)
    data 'data'
  end
end
