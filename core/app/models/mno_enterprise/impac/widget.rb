module MnoEnterprise
  class Impac::Widget < BaseResource

    attributes :name, :width, :widget_category, :settings

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event
      name
    end

  end
end
