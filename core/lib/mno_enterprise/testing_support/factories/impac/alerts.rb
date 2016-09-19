FactoryGirl.define do

  factory :mno_enterprise_impac_alert, :class => 'Impac::Alert' do
    factory :impac_alert, class: MnoEnterprise::Impac::Alert do

      sequence(:id) { |n| n }
      # Mno-hub is sending back a impac_kpi_id, and with Her, the factory objects aren't working so well...
      # kpi { build(:impac_kpi).attributes }
      impac_kpi_id 1
      service "inapp"
      title "Test Alert"
      recipients [{id: 1, email: 'test@maestrano.com'}]

      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
