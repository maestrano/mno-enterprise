module MnoEnterprise
  class Value < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :data, type: :string
    has_one :field

  end
end
