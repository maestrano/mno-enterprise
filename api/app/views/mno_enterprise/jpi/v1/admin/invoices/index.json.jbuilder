json.extract! @invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug
json.organization @invoice.organization, :id, :name
