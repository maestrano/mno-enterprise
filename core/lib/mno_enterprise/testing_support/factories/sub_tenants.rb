# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do

  factory :sub_tenant, class: MnoEnterprise::SubTenant do
    sequence(:id)
    name 'SubTenant'
    # Properly build the resource with Her
    initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
  end
end
