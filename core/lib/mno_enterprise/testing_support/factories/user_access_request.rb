FactoryGirl.define do
  factory :user_access_request, class: MnoEnterprise::UserAccessRequest do
    sequence(:id, &:to_s)
    status 'requested'
    user { build(:user) }
    requester { build(:user) }
  end
end
