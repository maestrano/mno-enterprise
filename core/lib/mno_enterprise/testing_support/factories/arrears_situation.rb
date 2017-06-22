FactoryGirl.define do
  factory :mno_enterprise_arrears_situation, :class => 'MnoEnterprise::ArrearsSituation' do

    factory :arrears_situation, class: MnoEnterprise::ArrearsSituation do
      sequence(:name) { |n| "Team#{n}" }
      payment Money.new(5680,'AUD')
      category 'payment_failed'
      status 'pending'

    end
  end
end
