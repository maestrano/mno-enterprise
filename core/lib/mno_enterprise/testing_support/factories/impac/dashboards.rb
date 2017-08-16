FactoryGirl.define do

  factory :mno_enterprise_impac_dashboard, :class => 'Impac::Dashboard' do
    factory :impac_dashboard, class: MnoEnterprise::Dashboard do
      sequence(:id, &:to_s)
      sequence(:name) { |n| "Random Dashboard #{n}" }

      initialize_with { new(attributes) }
    end
  end
end
