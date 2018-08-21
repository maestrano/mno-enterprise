# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_tenant_invoice, :class => 'TenantInvoice' do

    factory :tenant_invoice, class: MnoEnterprise::TenantInvoice do
      sequence(:id)
      sequence(:slug) { |n| "201504-NU#{n}" }
      organization_id 265

      started_at 28.days.ago
      ended_at 3.days.ago
      created_at 3.days.ago
      updated_at 1.hour.ago
      paid_at nil

      total_commission_amount Money.new(0,'AUD')
      total_portfolio_amount Money.new(0,'AUD')
      non_commissionable_amount Money.new(0,'AUD')
      mno_commission_amount Money.new(0,'AUD')

      # Make sure the object is not dirty
      initialize_with { new(attributes).tap { |e| e.clear_changes_information } }
    end

  end
end
