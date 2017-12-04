# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do

  factory :orga_relation, class: MnoEnterprise::OrgaRelation do
    sequence(:id, &:to_s)
    user_id '265'
    organization_id '265'
    role 'Admin'
    trait :super_admin do
      role 'Super Admin'
    end
  end
end
