# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_organization, :class => 'Organization' do
    
    factory :organization, class: MnoEnterprise::Organization do
      sequence(:id)
      name "Doe Inc"
      role "Admin"
      created_at 3.days.ago
      updated_at 1.hour.ago
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
    
  end
end
