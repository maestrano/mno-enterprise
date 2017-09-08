module MnoEnterprise
  class Bill < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :description, type: :string
    property :price_cents, type: :integer
    property :currency, type: :string
    property :adjustment, type: :boolean

    has_one :billable
    has_one :invoice
  end
end
