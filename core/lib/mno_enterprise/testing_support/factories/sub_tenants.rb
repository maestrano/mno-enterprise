# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sub_tenant, class: MnoEnterprise::SubTenant do
    sequence(:id)
    name 'SubTenant'
  end
end
