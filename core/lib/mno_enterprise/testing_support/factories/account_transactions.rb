# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_account_transaction, class: 'AccountTransaction' do

    factory :account_transaction, class: MnoEnterprise::AccountTransaction do
      sequence(:id, &:to_s)
      currency 'AUD'
      amount_cents 1200
      created_at 3.days.ago
      updated_at 1.hour.ago
      side 'credit'
      description 'Test Description'
      has_myob_essentials_only false
      credit_account_id nil
    end
  end
end
