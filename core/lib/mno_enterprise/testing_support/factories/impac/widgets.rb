FactoryGirl.define do
    
  factory :mno_enterprise_impac_widget, :class => 'Impac::Widget' do
    factory :impac_widget, class: MnoEnterprise::Impac::Widget do
      sequence(:id) { |n| n }
      sequence(:name) { |n| "Random Widget #{n}" }
      widget_category "widget_endpoint"
      width 3
      dashboard { build(:impac_dashboard).attributes }
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
