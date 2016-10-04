FactoryGirl.define do

  factory :mno_enterprise_impac_kpi, :class => 'Impac::Kpi' do
    factory :impac_kpi, class: MnoEnterprise::Impac::Kpi do

      sequence(:id) { |n| n }
      dashboard { build(:impac_dashboard).attributes }
      endpoint "finance/revenue"
      element_watched "evolution"

      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
