json.invoices do
  json.array! organization.invoices.order_by('ended_at.desc') do |invoice|
    json.started_at invoice.started_at
    json.ended_at invoice.ended_at
    json.amount AccountingjsSerializer.serialize(invoice.total_due)
    json.paid invoice.paid?
  end
end
