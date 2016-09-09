module MnoEnterprise
  class Impac::Kpi < BaseResource

    attributes :settings, :targets, :extra_params, :endpoint, :source, :element_watched

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    
  end
end
