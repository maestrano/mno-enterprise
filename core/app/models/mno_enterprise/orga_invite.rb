module MnoEnterprise
  class OrgaInvite < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time

    custom_endpoint :accept, on: :member, request_method: :patch
    custom_endpoint :decline, on: :member, request_method: :patch

    def to_audit_event
      self.attributes.slice(:team_id, :user_role, :user_email, :user_id, :referrer_id, :organization_id)
    end

    # Add the user to the organization and update the status of the invite
    # Add team
    def accept!(user = self.user)
      result = self.accept(data: { attributes: { user_id: user.id } } )
      process_custom_result(result)
    end

    def decline!
      process_custom_result(decline)
    end

    # Check whether the invite is expired or not
    def expired?
      self.status != 'pending' || self.created_at < 3.days.ago
    end

    def to_audit_event
      self.attributes.slice(:team_id, :user_role, :user_email, :user_id, :referrer_id, :organization_id)
    end

  end
end
