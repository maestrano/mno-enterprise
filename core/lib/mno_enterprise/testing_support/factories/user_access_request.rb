FactoryGirl.define do
  factory :user_access_request, class: MnoEnterprise::UserAccessRequest do
    sequence(:id, &:to_s)
    status 'requested'
    user { build(:user) }
    requester { build(:user) }
    created_at 2.hour.ago
    updated_at 1.hour.ago
    approved_at 1.hour.ago
  end
end
