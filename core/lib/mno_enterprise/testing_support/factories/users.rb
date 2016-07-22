# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do

  factory :user, class: MnoEnterprise::User do
    sequence(:id)
    sequence(:uid) { |n| "usr-fda9#{n}" }
    name "John"
    surname "Doe"
    sequence(:email) { |n| "john.doe#{n}@maestrano.com" }
    company "Doe Inc."
    phone "449 789 456"
    phone_country_code "AU"
    geo_country_code "AU"
    geo_state_code "NSW"
    geo_city "Sydney"
    created_at 2.days.ago
    updated_at 2.days.ago
    sso_session "1fdd5sf5a73D7sd1as2a4sd541"
    admin_role nil

    confirmation_sent_at 2.days.ago
    confirmation_token "wky763pGjtzWR7dP44PD"
    confirmed_at 1.days.ago

    trait :unconfirmed do
      confirmed_at nil
    end

    trait :admin do
      admin_role 'admin'
    end

    trait :staff do
      admin_role 'staff'
    end

    trait :with_deletion_request do
      deletion_request { build(:deletion_request).attributes }
    end

    trait :with_organizations do
      organizations { [build(:organization).attributes] }
    end

    # Properly build the resource with Her
    initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
  end
end
