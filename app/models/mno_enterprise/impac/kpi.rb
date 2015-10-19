module MnoEnterprise
  class Impac::Kpi < BaseResource

    attributes :name, :settings, :target, :extra_param, :endpoint, :source, :element_watched
    
    belongs_to :impac_dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'

  end
end
