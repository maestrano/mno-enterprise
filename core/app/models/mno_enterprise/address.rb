module MnoEnterprise
  class Address < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    has_one :owner
  end
end
