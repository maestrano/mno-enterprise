FactoryGirl.define do

  # Tenant from an old MnoHub (<= v1.0.2)
  # TODO: Remove once all mnohub are migrated to newer versions
  factory :old_tenant, class: MnoEnterprise::Tenant do
    last_portfolio_amount Money.new(65644,'AUD')
    last_customers_invoicing_amount Money.new(687994,'AUD')
    last_customers_outstanding_amount Money.new(178986,'AUD')
    last_commission_amount Money.new(412345,'AUD')

    # Properly build the resource with Her
    initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
  end

  factory :tenant, parent: :old_tenant do
    current_billing_amount Money.new(123456, 'AUD')
  end
end
