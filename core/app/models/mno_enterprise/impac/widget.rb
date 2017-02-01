module MnoEnterprise
  class Impac::Widget < BaseResource

    # TODO: change :widget_category to :endpoint when mnohub migrated to new model
    attributes :name, :width, :widget_category, :settings
    alias_attribute :endpoint, :widget_category

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event
      { name: name }
    end

  end
end
