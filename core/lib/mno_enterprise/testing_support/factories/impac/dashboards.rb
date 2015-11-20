FactoryGirl.define do
    
  factory :mno_enterprise_impac_dashboard, :class => 'Impac::Dashboard' do
    factory :impac_dashboard, class: MnoEnterprise::Impac::Dashboard do
      sequence(:id) { |n| n }
      sequence(:name) { |n| "Random Dashboard #{n}" }

      # Problem with polymorphic association ?...
      # owner { build(:user).attributes }

      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
