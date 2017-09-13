# Read about factories at https://github.com/thoughtbot/factory_girl

# This is an API resource factory generating a Hash to be used in API stubs
# Use as such: build(:api_user)
# See http://stackoverflow.com/questions/10032760/how-to-define-an-array-hash-in-factory-girl
FactoryGirl.define do

  factory :user, class: MnoEnterprise::User do
    sequence(:id, &:to_s)
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
    account_frozen false
    confirmation_sent_at 2.days.ago
    confirmation_token "wky763pGjtzWR7dP44PD"
    confirmed_at 1.days.ago.round(0)
    current_sign_in_at 1.days.ago
    current_sign_in_ip '184.95.86.77'
    last_sign_in_at 1.day.ago
    last_sign_in_ip '184.42.42.42'
    sign_in_count 1
    deletion_requests []
    teams []
    kpi_enabled true
    organizations []
    orga_relations []
    user_access_requests []
    dashboards []
    metadata {{}}
    external_id 1
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
      deletion_request { build(:deletion_request) }
    end

    trait :with_organizations do
      organizations { [build(:organization)] }
    end

    trait :kpi_enabled do
      kpi_enabled true
    end

    trait :with_clients do
      clients { [build(:organization)] }
    end

    trait :persisted do
      initialize_with do
        new(attributes).tap {|e| e.clear_changes_information}.tap {|u| u.mark_as_persisted!}
      end
    end

    # Make sure the object is not dirty
    initialize_with { new(attributes).tap { |e| e.clear_changes_information } }
  end
end
