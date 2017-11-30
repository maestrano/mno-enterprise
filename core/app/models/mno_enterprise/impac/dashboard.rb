module MnoEnterprise
  class Impac::Dashboard < BaseResource

    attributes :full_name, :widgets_order, :settings, :organization_ids, :widgets_templates, :currency, :published, :dashboard_type

    has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'
    belongs_to :owner, polymorphic: true
    default_scope -> { where(dashboard_type: 'dashboard') }
    scope :templates, -> { where(dashboard_type: 'template') }
    scope :published_templates, -> { where(dashboard_type: 'template', published: true) }

    custom_post :copy

    #============================================
    # Instance methods
    #============================================
    # Return the full name of this dashboard
    # Currently a simple accessor to the dashboard name (used to include the company name)
    def full_name
      self.name
    end

    # Return all the organizations linked to this dashboard and to which the user has access
    # If the dashboard is a template, return all the current user's organizations
    def organizations(org_list = nil)
      if org_list
        return org_list if dashboard_type == 'template'
        org_list.to_a.select { |e| organization_ids.include?(e.uid) || organization_ids.include?(e.id) }
      else
        MnoEnterprise::Organization.where('uid.in' => organization_ids).to_a
      end
    end

    # Filter widgets list based on config
    def filtered_widgets_templates
      if MnoEnterprise.widgets_templates_listing
        return self.widgets_templates.select do |t|
          MnoEnterprise.widgets_templates_listing.include?(t[:path])
        end
      else
        return self.widgets_templates
      end
    end

    def to_audit_event
      { name: name }
    end

    def copy(owner, name, organization_ids)
      owner_type = owner.class.name.demodulize
      attrs = {
        id: self.id,
        name: name,
        organization_ids: organization_ids,
        owner_type: owner_type,
        owner_id: owner.id
      }
      self.class.copy(attrs)
    end
  end
end
