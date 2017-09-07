json.invoice do
  json.partial! 'invoice', invoice: @invoice
  json.organization @invoice.organization, :id, :name

  json.adjustments @invoice.bills.select { |bill| bill.billable.type == 'organizations' } do |bill|
    json.extract! bill, :id, :end_user_price_cents, :currency, :description
  end

  json.bills @invoice.bills.reject { |bill| bill.billable.type == 'organizations' } do |bill|
    json.extract! bill, :id, :end_user_price_cents, :currency, :description
    json.billable_name bill.billable.name
  end
end
