module MnoEnterprise
  class Widget < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    def to_audit_event
      {name: name}
    end

  end
end
