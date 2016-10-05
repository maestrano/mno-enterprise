FactoryGirl.define do
  factory :identity, class: MnoEnterprise::Identity do
    provider 'someprovider'
    uid '123456'

    # Properly build the resource with Her
    initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
  end
end
