# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_app_instance, :class => 'AppInstance' do

    factory :app_instance, class: MnoEnterprise::AppInstance do
      sequence(:id, &:to_s)
      sequence(:uid) { |n| "bla#{1}.mcube.co" }
      name 'SomeApp'
      status 'running'
      created_at 3.days.ago
      updated_at 1.hour.ago
      started_at 3.days.ago
      stack 'cube'
      terminated_at nil
      stopped_at nil
      billing_type 'hourly'
      autostop_at nil
      autostop_interval nil
      next_status nil
      soa_enabled true
      oauth_keys_valid true
      oauth_company 'oauth company'
      app_nid 'app-nid'
      per_user_licence 1
      durations { {"provisioning"=>120, "starting"=>90, "stopping"=>60, "terminating"=>40} }
      app { build(:app, nid: app_nid) }
      sequence(:owner) { |n| build(:organization, id: n.to_s) }
      sequence(:owner_id, &:to_s)
      addon_organization nil
      channel_id nil
      metadata nil
    end
  end
end
