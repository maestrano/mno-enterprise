module MnoEnterprise
  class Impac::Dashboard < BaseResource

    attributes :name, :widgets_order, :organization_ids, :widgets_templates, :currency

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
      MnoEnterprise::Organization.where('uid.in' => self.organization_ids).to_a
    end

    def sorted_widgets
      order = self.widgets_order.map(&:to_i) | self.widgets.map{|w| w.id }
      order.map { |id| self.widgets.to_a.find{ |w| w.id == id} }.compact
    end

    def to_audit_event
      name
    end
  end
end
