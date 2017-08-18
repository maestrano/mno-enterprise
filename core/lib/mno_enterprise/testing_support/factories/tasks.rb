FactoryGirl.define do
  factory :mno_enterprise_task, :class => 'MnoEnterprise::Task' do

    factory :task, class: MnoEnterprise::Task do
      sequence(:id)
      owner {build(:orga_relation).attributes}
      sequence(:title) { |n| "Task Title #{n}" }
      sequence(:message) { |n| "Message: #{n}" }
      due_date 1.day.ago
    end
  end
end
