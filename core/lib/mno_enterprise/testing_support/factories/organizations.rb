# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_organization, :class => 'Organization' do

    factory :organization, class: MnoEnterprise::Organization do
      sequence(:id, &:to_s)
      sequence(:uid) { |n| "org-fab3#{n}" }
      name 'Doe Inc'
      role 'Admin'
      created_at 3.days.ago
      updated_at 1.hour.ago
      in_arrears? false
      billing_currency 'AUD'
      has_myob_essentials_only false
      orga_invites []
      orga_relations []
      users []
      credit_card_id nil
      credit_card nil
      invoices []
      main_address nil
      trait :with_org_invites do
        org_invites { [build(:org_invite)] }
      end
    end
  end
end
