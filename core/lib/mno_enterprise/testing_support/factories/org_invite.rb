# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_org_invite, :class => 'MnoEnterprise::OrgInvite' do
    
    factory :org_invite, class: MnoEnterprise::OrgInvite do
      sequence(:id) 
      sequence(:token) { |n| "dfhsohflsklddfdsJDasldnjsaHsnjdlsa#{n}" } 
      sequence(:user_email) { |n| "jack.doe#{n}@maestrano.com" }
      status "pending"
      user { build(:user).attributes }
      organization { build(:organization).attributes }
      referrer { build(:user).attributes }
      team { build(:team).attributes }
      user_role 'Member'
      
      created_at 1.days.ago
      updated_at 1.hour.ago
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }

      trait :expired do
        created_at 1.month.ago
      end
    end
  end
end
