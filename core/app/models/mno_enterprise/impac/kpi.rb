module MnoEnterprise
  class Impac::Kpi < BaseResource

    attributes :settings, :targets, :extra_params, :endpoint, :source, :element_watched, :extra_watchables

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    belongs_to :widget, class_name: 'MnoEnterprise::Impac::Widget'
    has_many :alerts, class_name: 'MnoEnterprise::Impac::Alert', dependent: :destroy

  end
end
