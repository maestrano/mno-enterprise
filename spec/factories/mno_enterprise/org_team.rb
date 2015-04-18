# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_org_team, :class => 'MnoEnterprise::OrgTeam' do
    
    factory :org_team, class: MnoEnterprise::OrgTeam do
      sequence(:id) 
      sequence(:name) { |n| "Team#{n}" } 

      created_at 3.days.ago 
      updated_at 1.hour.ago
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
