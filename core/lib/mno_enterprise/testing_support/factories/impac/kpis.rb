FactoryGirl.define do

  factory :mno_enterprise_impac_kpi, :class => 'Impac::Kpi' do
    factory :impac_kpi, class: MnoEnterprise::Kpi do

      sequence(:id, &:to_s)
      dashboard { build(:impac_dashboard) }
      endpoint 'finance/revenue'
      element_watched 'evolution'
      source 'source'
      targets 'target'
      settings {{}}
      extra_watchables {{}}
      extra_params {{}}
      alerts {[]}

    end
  end
end
