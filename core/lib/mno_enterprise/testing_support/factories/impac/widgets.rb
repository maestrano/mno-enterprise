FactoryGirl.define do

  factory :mno_enterprise_impac_widget, :class => 'Impac::Widget' do
    factory :impac_widget, class: MnoEnterprise::Widget do
      sequence(:id, &:to_s)
      sequence(:name) { |n| "Random Widget #{n}" }
      widget_category 'widget_endpoint'
      width 3
      endpoint 'endpoint'
      dashboard { build(:impac_dashboard).attributes }

      initialize_with { new(attributes) }
    end
  end
end
