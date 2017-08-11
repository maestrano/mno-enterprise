module MnoEnterprise
  class Category < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :name, type: :string
    property :parent_id, type: :string

    def to_audit_event
      { id: id, name: name }
    end
  end
end

