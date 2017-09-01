FactoryGirl.define do
  factory :product_markup, class: MnoEnterprise::ProductMarkup do
    sequence(:id, &:to_s)
    organization_name "My Org"
    organization_id "org-132"
    product_name "My Product"
    product_id "product-123"
    product nil
    organization nil
  end
end
