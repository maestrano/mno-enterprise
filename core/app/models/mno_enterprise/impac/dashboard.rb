module MnoEnterprise
  class Impac::Dashboard < BaseResource

    attributes :full_name, :widgets_order, :settings, :organization_ids, :widgets_templates, :currency

    has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'
    belongs_to :owner, polymorphic: true
    default_scope -> { where(dashboard_type: 'dashboard') }
    scope :templates, -> { where(dashboard_type: 'template') }

    #============================================
    # Instance methods
    #============================================
    # Return the full name of this dashboard
    # Currently a simple accessor to the dashboard name (used to include the company name)
    def full_name
      self.name
    end

    # Return all the organizations linked to this dashboard and to which
    # the user has access
    def organizations(org_list = nil)
      if org_list
        org_list.to_a.select { |e| self.organization_ids.include?(e.uid) }
      else
        MnoEnterprise::Organization.where('uid.in' => self.organization_ids).to_a
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
      {
        name: name,
        organization_id: (owner_type == 'MnoEnterprise::Organization') ? owner_id : nil
      }
    end
  end
end
