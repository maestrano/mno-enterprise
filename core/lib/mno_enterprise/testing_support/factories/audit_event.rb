FactoryGirl.define do
  factory :mno_enterprise_audit_event, :class => 'AuditEvent' do

    factory :audit_event, class: MnoEnterprise::AuditEvent do
      sequence(:key) { |n| "event-fab3#{n}" }
      user_id 1
      description 'Blabla'
      user { {name: 'John', surname: 'Doe'} }

      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
