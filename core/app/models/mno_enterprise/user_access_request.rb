module MnoEnterprise
  class UserAccessRequest < BaseResource
    # Expiration timeout for pending and active requests
    EXPIRATION_TIMEOUT = 24.hours

    property :created_at, type: :time
    property :updated_at, type: :time
    property :approved_at, type: :time
    property :requester_id, type: :string
    property :user_id, type: :string

    custom_endpoint :approve, on: :member, request_method: :patch
    custom_endpoint :deny, on: :member, request_method: :patch

    def self.active_requested(user_id)
      includes(:requester).where(user_id: user_id, status: 'requested', 'created_at.gt': EXPIRATION_TIMEOUT.ago)
    end


    def to_audit_event
      { id: id, user_id: user_id, requester_id: requester_id }
    end

    def current_status
      if (status == 'approved' && approved_at <= EXPIRATION_TIMEOUT.ago) || (status == 'requested' && created_at < EXPIRATION_TIMEOUT.ago)
        'expired'
      else
        status
      end
    end
  end
end
