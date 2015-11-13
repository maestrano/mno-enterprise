json.invoices do
  json.array! organization.invoices.order_by('ended_at.desc') do |invoice|
    json.period invoice.period_label
    json.amount AccountingjsSerializer.serialize(invoice.total_due)
    json.paid invoice.paid?
    json.link mno_enterprise.invoice_path(invoice.slug)
  end
end
