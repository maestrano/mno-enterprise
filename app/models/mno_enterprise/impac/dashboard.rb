module MnoEnterprise
  class Impac::Dashboard < BaseResource
    include Her::Model
    # collection_path "dashboards"

    attributes :name, :settings

	  # has_many :widgets, dependent: :destroy, class_name: 'MnoEnterprise::Impac::Widget', foreign_key: 'analytics_dashboard_id'
	  has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget', dependent: :destroy
	  belongs_to :owner, polymorphic: true

    #============================================
	  # Dynamic accessors for stored Array
	  #============================================
	  def widgets_order
    	self.settings ? self.settings[:widgets_order] || [] : []
	  end

    def widgets_order= (value)
    	self.settings[:widgets_order] = value
    end

    def organization_ids
    	self.settings ? self.settings[:organization_ids] || [] : []
    end

    def organization_ids= (value)
    	self.settings[:organization_ids] = value.map{|org_id| MnoEnterprise::Organization.find(org_id).uid}
    end
	  
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
	    order = self.widgets_order | self.widgets.map(&:id)
	    order.map { |id| self.widgets.to_a.find{ |w| w.id == id} }.compact
	  end

  end
end