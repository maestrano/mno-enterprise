FactoryGirl.define do
  factory :subscription_event, class: MnoEnterprise::SubscriptionEvent do
    sequence(:id, &:to_s)
    obsolete false
    user_name 'first last'

    subscription { build(:subscription) }
  end
end
