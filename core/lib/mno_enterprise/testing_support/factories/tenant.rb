FactoryGirl.define do
  factory :tenant, class: MnoEnterprise::Tenant do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "Tenant#{n}" }

    frontend_config {}
  end
end
