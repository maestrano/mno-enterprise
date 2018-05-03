FactoryGirl.define do
  factory :main_address, class: MnoEnterprise::Address do
    sequence(:id, &:to_s)
    street '404 5th Ave'
    city 'New York'
    state_code 'NY'
    postal_code '10018'
    country_code 'US'
    main true
    owner { build(:organization) }
  end
end
