json.invoice @invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug,
             :tax_pips_applied, :billing_address
json.organization @invoice.organization, :id, :name
json.bills @invoice.bills do |bill|
  json.extract! bill, :id, :price_cents, :currency, :billing_type
  json.billable_type bill.billable.type
  json.billable_name bill.billable.name
end
