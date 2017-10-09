# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_credit_card, :class => 'CreditCard' do
    factory :credit_card, class: MnoEnterprise::CreditCard do
      sequence(:id, &:to_s)
      organization_id 265
      created_at 3.days.ago
      updated_at 1.hour.ago
      title 'Mr.'
      first_name 'John'
      last_name 'Doe'
      country 'AU'
      masked_number 'XXXX-XXXX-XXXX-4242'
      number nil
      month 3
      year 2025
      billing_address '102 Somewhere Street'
      billing_city 'Sydney'
      billing_postcode '2010'
      billing_country 'AU'
      verification_value 'CVV'

    end

  end
end
