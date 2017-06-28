FactoryGirl.define do
  factory :product, class: MnoEnterprise::Product do
    sequence(:id, &:to_s)
    sequence(:nid) { |n| "cld-aaa#{n}" }
    name "My Product"
    active true
    product_type :application
    externally_provisioned true
  end
end
