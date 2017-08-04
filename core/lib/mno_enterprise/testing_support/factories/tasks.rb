FactoryGirl.define do
  factory :mno_enterprise_task, :class => 'MnoEnterprise::Task' do
    
    factory :task, class: MnoEnterprise::Task do
      title 'title'
      message 'message'
      due_date 'due_date'
    end
  end
end
