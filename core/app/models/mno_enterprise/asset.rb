module MnoEnterprise
  class Asset < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    has_one :product

    def to_audit_event
      {
        id: id,
        name: name
      }
    end
  end
end
