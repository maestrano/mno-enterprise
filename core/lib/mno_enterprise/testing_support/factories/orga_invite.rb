# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_org_invite, :class => 'OrgaInvite' do

    factory :orga_invite, class: MnoEnterprise::OrgaInvite do
      sequence(:id, &:to_s)
      sequence(:token) { |n| "dfhsohflsklddfdsJDasldnjsaHsnjdlsa#{n}" }
      sequence(:user_email) { |n| "jack.doe#{n}@maestrano.com" }
      status "pending"
      user { build(:user) }
      organization { build(:organization) }
      referrer { build(:user) }
      team { build(:team) }
      user_role 'Member'

      created_at 1.days.ago
      updated_at 1.hour.ago

      trait :expired do
        created_at 1.month.ago
      end
    end
  end
end
