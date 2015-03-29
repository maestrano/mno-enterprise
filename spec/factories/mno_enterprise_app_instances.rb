# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_app_instance, :class => 'AppInstance' do
    
    factory :app_instance, class: MnoEnterprise::AppInstance do
      sequence(:id) 
      sequence(:uid) { |n| "bla#{1}.mcube.co" } 
      name "SomeApp"
      status "running"
      created_at 3.days.ago 
      updated_at 1.hour.ago 
      started_at 3.days.ago
      stack "cube"
      terminated_at nil
      stopped_at nil
      billing_type "hourly"
      autostop_at nil
      autostop_interval nil
      next_status nil
      soa_enabled true
      
      app { build(:app).attributes }
      
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
