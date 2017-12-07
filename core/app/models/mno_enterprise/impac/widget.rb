module MnoEnterprise
  class Impac::Widget < BaseResource

    # TODO: remove :widget_category when mnohub migrated to new model
    attributes :name, :width, :widget_category, :settings, :endpoint

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'

    def to_audit_event
      if organization_ids.present?
        organization = MnoEnterprise::Organization.find_by(uid: organization_ids.first)
        { name: name, organization_id: organization.id }
      else
        { name: name }
      end
    end

    def organizations(orgs = nil)
      if orgs.present?
        orgs.select { |org| organization_ids.include?(org.uid) }.to_a
      else
        MnoEnterprise::Organization.where('uid.in' => organization_ids).to_a
      end
    end

    private

    def organization_ids
      @organization_ids ||= (settings.present? && settings['organization_ids']).to_a
    end
  end
end
