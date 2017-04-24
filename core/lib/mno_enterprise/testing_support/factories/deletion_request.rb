# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do

  factory :deletion_request, class: MnoEnterprise::DeletionRequest do
    sequence(:id, &:to_s)
    sequence(:token) { |n| "1dfg567fda44f87ds89F7DS8#{n}" }
    status 'pending'
    created_at Time.now
    updated_at Time.now
  end

end
