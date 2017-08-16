FactoryGirl.define do
  factory :tenant_reporting, class: MnoEnterprise::TenantReporting do
    sequence(:id, &:to_s)

    last_portfolio_amount Money.new(65644,'AUD')
    last_customers_invoicing_amount Money.new(687994,'AUD')
    last_customers_outstanding_amount Money.new(178986,'AUD')
    last_commission_amount Money.new(412345,'AUD')
    current_billing_amount Money.new(123456, 'AUD')
  end
end
