json.invoice do
  json.partial! 'invoice', invoice: @invoice
  json.organization @invoice.organization, :id, :name
  json.adjustments @invoice.bills.select{ |bill| bill.billable_type == 'Organization' } do |bill|
    json.extract! bill, :id, :price_cents, :currency, :billable_description
  end
  json.bills @invoice.bills.select{ |bill| !(bill.billable_type == 'Organization') } do |bill|
    json.extract! bill, :id, :price_cents, :currency, :billing_type, :billable_type, :billable_description
    json.billable_name bill.billable
  end
end
