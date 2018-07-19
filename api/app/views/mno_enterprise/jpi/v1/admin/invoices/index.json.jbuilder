json.invoices(@invoices) do |invoice|
  json.extract! invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug
  if invoice.organization
    json.organization invoice.organization, :id, :name
  end
end
