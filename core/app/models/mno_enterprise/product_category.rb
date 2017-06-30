module MnoEnterprise
  class ProductCategory < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    def to_audit_event
      {
        id: id,
        name: name
      }
    end
  end
end
