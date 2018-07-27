FactoryGirl.define do
  factory :tenant, class: MnoEnterprise::Tenant do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "Tenant#{n}" }
    domain 'tenant.domain.test'
    frontend_config { {} }
    metadata { {app_management: "marketplace", can_manage_organization_credit: true} }
    tenant_company { build(:organization) }
  end
end
