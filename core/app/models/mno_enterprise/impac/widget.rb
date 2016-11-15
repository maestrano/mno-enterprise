module MnoEnterprise
  class Impac::Widget < BaseResource

    attributes :name, :width, :widget_category, :settings

    alias_attribute :endpoint, :widget_category

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event
      {name: name}
    end

  end
end
