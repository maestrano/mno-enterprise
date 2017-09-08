json.invoice do
  json.extract! @invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug, :tax_pips_applied
  json.organization @invoice.organization, :id, :name

  json.adjustments @invoice.bills.select(&:adjustment) do |bill|
    json.extract! bill, :id, :end_user_price_cents, :currency, :description
  end

  json.bills @invoice.bills.reject(&:adjustment) do |bill|
    json.extract! bill, :id, :end_user_price_cents, :currency, :description
    json.billing_group bill.billing_group
  end
end
