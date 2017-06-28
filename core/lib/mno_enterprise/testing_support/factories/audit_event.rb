FactoryGirl.define do
  factory :mno_enterprise_audit_event, :class => 'AuditEvent' do

    factory :audit_event, class: MnoEnterprise::AuditEvent do
      sequence(:id, &:to_s)
      sequence(:key) { |n| "event-fab3#{n}" }
      created_at 2.days.ago
      updated_at 2.days.ago
      user_id 1
      description 'Blabla'
      metadata 'metadata'
      organization_id '1'
      organization { {name: 'Org'} }
      user { {name: 'John', surname: 'Doe'} }
    end
  end
end
