FactoryGirl.define do
  factory :product_pricing, class: MnoEnterprise::ProductPricing do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "Product #{n}" }
    description 'Basic pricing plan'
    free false
    free_trial_enabled true
    free_trial_duration 1
    free_trial_unit 'month'
    position 1
    per_duration "per duration"
    per_unit "per unit"
    prices {[]}
    external_id "external id"
    product_id 1
  end
end
