module MnoEnterprise
  class UserAccessRequest < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :approved_at, type: :time
    property :requester_id, type: :string
    property :user_id, type: :string

    custom_endpoint :approve, on: :member, request_method: :patch
    custom_endpoint :deny, on: :member, request_method: :patch

    def to_audit_event
      { id: id, user_id: user_id, requester_id: requester_id }
    end

  end
end
