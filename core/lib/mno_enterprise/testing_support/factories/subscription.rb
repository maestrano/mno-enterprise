FactoryGirl.define do
  factory :subscription, class: MnoEnterprise::Subscription do
    sequence(:id, &:to_s)
    status 'requested'
    start_date Date.today
    end_date Date.today + 1.year
    max_licenses 10
    available_licenses 10

    product_instance { build(:product_instance) }
    pricing { build(:product_pricing) }
    contract { build(:product_contract) }
    organization { build(:organization) }
    user { build(:user) }
  end
end
