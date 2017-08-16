module MnoEnterprise
  class Dashboard < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time
    property :owner_id, type: :string

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
        MnoEnterprise::Organization.where(uid: self.organization_ids).to_a
      end
    end

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
      ids = self.widgets_order | self.widgets.map(&:id)
      widgets_per_ids = self.widgets.each_with_object({}) do |w, hash|
        hash[w.id] = w
      end
      ids.map { |i| widgets_per_ids[i] }
    end

    def to_audit_event
      {
        name: name,
        owner_id: owner_id,
        owner_type: owner_type
      }
    end

  end
end
