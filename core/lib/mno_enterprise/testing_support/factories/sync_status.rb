FactoryGirl.define do
  factory :sync_status, class: MnoEnterprise::SyncStatus do
    sequence(:id, &:to_s)
    created_at 1.days.ago
    started_at 1.days.ago
    finished_at 1.days.ago
    updated_at 1.days.ago
    status 'success'
    messages 'This is a message.'
    progress 100
  end
end
