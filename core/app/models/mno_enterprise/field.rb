module MnoEnterprise
  class Field < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :name, type: :string
    property :description, type: :string
    property :field_type, type: :string
    property :required, type: :boolean
    property :section, type: :string
    property :min_length, type: :string
    property :max_length, type: :string
    property :visible, type: :boolean
    property :multiple, type: :boolean

    def to_audit_event
      { id: id, name: name }
    end
  end
end
