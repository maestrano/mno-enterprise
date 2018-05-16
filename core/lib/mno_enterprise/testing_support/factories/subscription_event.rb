FactoryGirl.define do
  factory :subscription_event, class: MnoEnterprise::SubscriptionEvent do
    sequence(:id, &:to_s)
    obsolete false

    subscription { build(:subscription) }
  end
end
