# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do
  factory :api_user, class: Hash do
    first_name "John"
    last_name "Doe"
    
    initialize_with { attributes }
  end
end
