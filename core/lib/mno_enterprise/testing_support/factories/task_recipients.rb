FactoryGirl.define do
  factory :mno_enterprise_task_recipient, :class => 'MnoEnterprise::TaskRecipient' do

    factory :task_recipient, class: MnoEnterprise::TaskRecipient do
      sequence(:id)
      user {build(:user).attributes}
      organization {build(:organization).attributes}
    end
  end
end
