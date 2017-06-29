module MnoEnterprise
  class ProductInstance < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    def to_audit_event
      {
        id: id,
        status: status,
        organization_id: organization_id
      }
    end
  end
end
