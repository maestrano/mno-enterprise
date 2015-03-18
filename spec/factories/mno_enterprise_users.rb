# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do
  
  factory :user, class: MnoEnterprise::User do
    sequence(:id) { |n| "usr-#{n}" }
    name "John"
    surname "Doe"
  end
  
  # API Response for user model
  factory :api_user, class: Hash do
    sequence(:id) { |n| "usr-#{n}" }
    name "John"
    surname "Doe"
    confirmation_token "wky763pGjtzWR7dP44PD"
    confirmed_at 3.days.ago.iso8601
    
    trait :unconfirmed do
      confirmed_at nil
    end
    
    initialize_with { attributes }
  end
  
  # API Response for RemoteUniquenessValidator
  factory :api_user_validate_uniqueness, class: Hash do
    
    trait :fail do
      errors { [{ 
        id: "897b7a80-adce-0132-8bfa-600308937d74",
        href: "https://maestrano.com/support",
        status: 400,
        code: "email-has-already-been-taken",
        title: "Email has already been taken",
        detail: "Email has already been taken"
      }] }
    end
    
    initialize_with { attributes }
  end
end
