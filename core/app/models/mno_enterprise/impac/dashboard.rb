module MnoEnterprise
  class Impac::Dashboard < BaseResource

    attributes :full_name, :widgets_order, :settings, :organization_ids, :widgets_templates, :currency

    has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget'
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi'
    belongs_to :owner, polymorphic: true

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
    def organizations
      MnoEnterprise::Organization.where('uid.in' => self.organization_ids).to_a
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
      name
    end
  end
end
