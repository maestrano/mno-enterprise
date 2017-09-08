module MnoEnterprise
  class Widget < BaseResource
    property  :dashboard_owner_uid, type: :string

    property :created_at, type: :time
    property :updated_at, type: :time

    def to_audit_event
      if settings.present? && settings['organization_ids'].present?
        organization = MnoEnterprise::Organization.where(uid: settings['organization_ids'].first).first
        { name: name, organization_id: organization.id }
      else
        { name: name }
      end
    end

  end
end
