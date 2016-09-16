FactoryGirl.define do
    
  factory :mno_enterprise_impac_alert, :class => 'Impac::Alert' do
    factory :impac_alert, class: MnoEnterprise::Impac::Alert do
      
      sequence(:id) { |n| n }
      kpi { build(:impac_kpi).attributes }
      service "inapp"
      title "Test Alert"
      recipients [{id: 1, email: 'test@maestrano.com'}]
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
