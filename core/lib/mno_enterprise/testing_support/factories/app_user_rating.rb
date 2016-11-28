# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_user_app_rating, :class => 'AppUserRating' do

    factory :app_user_rating, class: MnoEnterprise::AppUserRating do
      sequence(:id)
      description 'Some Description'
      status 'approved'
      rating 3
      app_id 'app-id'
      app_name 'the app'
      user_id 'usr-11'
      user_name 'Jean Bon'
      organization_id 'org-11'
      organization_name 'Organization 11'
      created_at 3.days.ago
      updated_at 1.hour.ago
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
