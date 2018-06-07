# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_team, :class => 'MnoEnterprise::Team' do

    factory :team, class: MnoEnterprise::Team do
      sequence(:id, &:to_s)
      sequence(:name) { |n| "Team#{n}" }

      created_at 3.days.ago
      updated_at 1.hour.ago
      organizations []
      users []
      user_ids []
      app_instances []
      product_instances []
    end
  end
end
