json.invoices do
  json.array! organization.invoices.order_by('ended_at.desc') do |invoice|
    json.period invoice.period_label
    json.amount invoice.total_due
    json.paid invoice.paid?
    json.link "/bla" #invoice_path(invoice.slug)
  end
end