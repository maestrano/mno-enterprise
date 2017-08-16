FactoryGirl.define do
  factory :identity, class: MnoEnterprise::Identity do
    sequence(:id, &:to_s)
    provider 'someprovider'
    uid '123456'
  end
end
