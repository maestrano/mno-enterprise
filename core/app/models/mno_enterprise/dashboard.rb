module MnoEnterprise
  class Dashboard < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time
    property :owner_id, type: :string

    has_one :owner

	  # TODO: APIv2 - Is this needed?
	  # default_scope -> { where(dashboard_type: 'dashboard') }

    custom_endpoint :copy, on: :collection, request_method: :post

    #============================================
    # Class methods
    #============================================
    def self.templates
      where(dashboard_type: 'template')
    end

    def self.published_templates
      where(dashboard_type: 'template', published: true)
    end

    #============================================
    # Instance methods
    #============================================
    # Return the full name of this dashboard
    # Currently a simple accessor to the dashboard name (used to include the company name)
    def full_name
      self.name
    end

    # Return all the organizations linked to this dashboard and to which the user has access
    # If the dashboard is a template, return all the current user's organization
    def organizations(org_list = nil)
      if org_list
        return org_list if dashboard_type == 'template'
        org_list.to_a.select { |e| self.organization_ids.include?(e.uid) }
      else
        MnoEnterprise::Organization.where(uid: self.organization_ids).to_a
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

    def sorted_widgets
      ids = self.widgets_order.map(&:to_s) | self.widgets.map(&:id)
      widgets_per_ids = self.widgets.each_with_object({}) do |w, hash|
        hash[w.id] = w
      end
      ids.map { |i| widgets_per_ids[i] }
    end

    def to_audit_event
      {
        name: name,
        owner_id: owner_id,
        owner_type: owner_type,
        organization_id: (owner_type == 'Organization') ? owner_id : nil
      }
    end

    def copy!(owner, name, organization_ids)
      owner_type = owner.class.name.demodulize
      attrs = {
        id: self.id,
        name: name,
        organization_ids: organization_ids,
        owner_type: owner_type,
        owner_id: owner.id
      }
      result = self.class.copy(id: id, data: { attributes: attrs })
      process_custom_result(result)
    end
  end
end
