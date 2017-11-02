# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :app, class: MnoEnterprise::App do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "TestApp#{n}" }
    nid { name.parameterize }
    sequence(:uid) { |n| "app-#{n}" }
    description "This is a description"
    created_at 1.day.ago
    updated_at 2.hours.ago
    logo "https://cdn.somedomain.com/app/2f4g2r474.jpg"
    website "https://www.testapp.com"
    slug { "#{id}-myapp" }
    categories ["CRM"]
    tags ['Foo', 'Bar']
    key_benefits ['Super', 'Hyper', 'Good']
    key_features ['Super', 'Hyper', 'Good']
    key_workflows ['1st workflow', '2nd workflow']
    known_limitations "No limitations"
    testimonials [{text: 'Bla', company: 'Doe Pty Ltd', author: 'John'}]
    worldwide_usage 120000
    tiny_description "A great app"
    stack 'cube'
    terms_url "http://opensource.org/licenses/MIT"
    support_url "http://example.com/support"
    metadata_url nil
    getting_started "Let's get started"
    details nil
    appinfo { {} }
    average_rating { rand(1..5) }
    sequence(:rank) { |n| n }
    running_instances_count { rand(0..10) }
    multi_instantiable true
    sso_enabled true
    api_key '96bdac9554418a8db9c374cc7f3f7e07af8954decc13f1c2edc4dcedfc0b57c8'
    free_trial_duration 20
    free_trial_unit 'days'
    pricing_plans { {
      'default' => [{name: 'Monthly Plan', price: '20.0', currency: 'AUD', factor: '/month'}]
    } }
    app_shared_entities { [] }
    pictures []
    subcategories []
    trait :cloud do
      stack 'cloud'
    end

    trait :connector do
      stack 'connector'
    end

    factory :cloud_app, traits: [:cloud]
    factory :connector_app, traits: [:connector]

  end
end
