# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_bill, class: 'Bill' do
    factory :bill, class: MnoEnterprise::Bill do
      sequence(:id)
      created_at 3.days.ago
      updated_at 1.hour.ago
      price_cents 2000
      end_user_price_cents 2400
      billing_group 'Some App'
      currency 'AUD'
      billable { build(:app_instance) }
      closed_end_user_price Money.new(7980,'AUD')
      closure_exchange_rate 1.51
    end
  end
end
