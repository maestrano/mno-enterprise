module MnoEnterprise
  class ProductInstance < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    def to_audit_event
      {
        id: id,
        status: status
      }
    end
  end
end
