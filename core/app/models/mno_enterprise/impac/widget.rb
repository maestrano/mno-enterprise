module MnoEnterprise
  class Impac::Widget < BaseResource

    # TODO: remove :widget_category when mnohub migrated to new model
    attributes :name, :width, :widget_category, :settings, :endpoint

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event

      if settings['organization_ids'].any?
        organization = MnoEnterprise::Organization.find_by(uid: settings['organization_ids'].first)
        { name: name, organization_id: organization.id }
      else
        { name: name }
      end

    end

  end
end
