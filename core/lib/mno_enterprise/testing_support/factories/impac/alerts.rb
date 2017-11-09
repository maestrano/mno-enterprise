FactoryGirl.define do

  factory :mno_enterprise_impac_alert, :class => 'Impac::Alert' do
    factory :impac_alert, class: MnoEnterprise::Alert do

      sequence(:id, &:to_s)
      kpi_id '1'
      service 'inapp'
      title 'Test Alert'
      webhook 'webhook'
      sent false
      recipients []
      settings {}
    end
  end
end
