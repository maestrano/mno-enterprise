FactoryGirl.define do
  factory :tenant, class: MnoEnterprise::Tenant do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "Tenant#{n}" }
    domain 'tenant.domain.test'
    frontend_config { {} }
    created_at 2.days.ago
    updated_at 2.days.ago
  end
end
