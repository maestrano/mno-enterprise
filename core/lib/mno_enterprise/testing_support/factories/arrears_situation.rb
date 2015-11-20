FactoryGirl.define do
  factory :mno_enterprise_arrears_situation, :class => 'MnoEnterprise::ArrearsSituation' do

    factory :arrears_situation, class: MnoEnterprise::ArrearsSituation do
      sequence(:name) { |n| "Team#{n}" }
      payment Money.new(5680,'AUD')
      category 'payment_failed'
      status 'pending'

      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
