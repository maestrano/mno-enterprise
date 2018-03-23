FactoryGirl.define do
  factory :subscription, class: MnoEnterprise::Subscription do
    sequence(:id, &:to_s)
    status 'requested'
    start_date Date.today
    end_date Date.today + 1.year
    currency 'USD'
    max_licenses 10
    available_licenses 10
    available_edit_actions ['SUSPEND', 'EDIT']

    product_instance { build(:product_instance) }
    product_pricing { build(:product_pricing) }
    product_contract { build(:product_contract) }
    organization { build(:organization) }
    user { build(:user) }
  end
end
