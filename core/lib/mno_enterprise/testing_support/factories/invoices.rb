# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_invoice, :class => 'Invoice' do
    factory :invoice, class: MnoEnterprise::Invoice do
      sequence(:id)
      sequence(:slug) { |n| "201504-NU#{n}" }

      started_at 28.days.ago
      ended_at 3.days.ago
      created_at 3.days.ago
      updated_at 1.hour.ago
      paid_at nil

      price Money.new(7980,'AUD')
      price_cents 7980
      currency 'AUD'

      billing_address "205 Bla Street, Sydney"
      total_due Money.new(7980,'AUD')
      total_payable Money.new(7980,'AUD')
      total_due_remaining Money.new(7980,'AUD')
      credit_paid Money.new(0,'AUD')

      tax_payable Money.new(590,'AUD')
      tax_due_remaining Money.new(590,'AUD')

      previous_total_due Money.new(0,'AUD')
      previous_total_paid Money.new(0,'AUD')

      tax_pips_applied 5000

      organization { build(:organization) }
      bills []

      billing_summary [
        {
          "name"=>"vTiger 5.4",
          "usage"=>"499h",
          "label"=>"vTiger",
          "price_tag"=>"$19.95",
          "lines"=>[
            {"label"=>"Application plan", "price_tag"=>"$19.95"}
          ]
        }
      ]
    end


  end
end
