FactoryGirl.define do
  factory :field, class: MnoEnterprise::Field do
    sequence(:id, &:to_s)
    name 'name'
  end
end
