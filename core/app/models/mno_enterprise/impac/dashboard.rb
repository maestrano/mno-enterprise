module MnoEnterprise
  class Impac::Dashboard < BaseResource

    attributes :full_name, :widgets_order, :settings, :organization_ids, :widgets_templates, :currency

    has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget', dependent: :destroy
    has_many :kpis, class_name: 'MnoEnterprise::Impac::Kpi', dependent: :destroy
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
      self.organization_ids.map do |uid|
        MnoEnterprise::Organization.find_by(uid: uid)
      end
    end

    def sorted_widgets
      order = self.widgets_order.map(&:to_i) | self.widgets.map{|w| w.id }
      order.map { |id| self.widgets.to_a.find{ |w| w.id == id} }.compact
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
