module MnoEnterprise
  class Impac::Widget < BaseResource

    # TODO: remove :widget_category when mnohub migrated to new model
    attributes :name, :width, :widget_category, :settings, :endpoint

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event
      { name: name }
    end

  end
end
