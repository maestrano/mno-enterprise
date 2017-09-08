FactoryGirl.define do
  factory :sub_tenant, class: MnoEnterprise::SubTenant do
    sequence(:id, &:to_s)
    name 'SubTenant'
  end
end
