# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_organization, :class => 'Organization' do
    
    factory :organization, class: MnoEnterprise::Organization do
      sequence(:id)
      sequence(:uid) { |n| "org-fab3#{n}" }
      name "Doe Inc"
      role "Admin"
      created_at 3.days.ago
      updated_at 1.hour.ago
      in_arrears? false

      trait :with_org_invites do
        org_invites { [build(:org_invite).attributes] }
      end
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
    
  end
end
