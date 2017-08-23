module MnoEnterprise
  class UserAccessRequest < BaseResource
    # Expiration timeout for pending and active requests
    EXPIRATION_TIMEOUT = 24.hours

    property :created_at, type: :time
    property :updated_at, type: :time
    property :approved_at, type: :time
    property :expiration_date, type: :time
    property :denied_at, type: :time
    property :revoked_at, type: :time
    property :requester_id, type: :string
    property :user_id, type: :string
    property :status

    custom_endpoint :approve, on: :member, request_method: :patch
    custom_endpoint :deny, on: :member, request_method: :patch
    custom_endpoint :revoke, on: :member, request_method: :patch

    def approve!
      input = { data: { attributes: { expiration_date: EXPIRATION_TIMEOUT.from_now} } }
      approve(input)
    end

    def self.active_requested(user_id)
      includes(:requester).where(user_id: user_id, status: 'requested', 'created_at.gt': EXPIRATION_TIMEOUT.ago)
    end

    def self.last_access_request(user_id)
      includes(:requester).where('requester_id.none' => true, user_id: user_id, status: 'approved').order(created_at: :desc).first
    end

    def to_audit_event
      { id: id, user_id: user_id, requester_id: requester_id , status: status}
    end

    def current_status
      if (status == 'approved' && expiration_date && Time.now > expiration_date ) || (status == 'requested' && created_at < EXPIRATION_TIMEOUT.ago)
        'expired'
      else
        status
      end
    end
  end
end
