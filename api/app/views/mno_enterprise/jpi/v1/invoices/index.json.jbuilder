json.invoices do
  json.array! @invoices do |invoice|
    json.started_at invoice.started_at
    json.ended_at invoice.ended_at
    json.amount AccountingjsSerializer.serialize(invoice.total_due)
    json.paid invoice.paid?
    json.link mno_enterprise.jpi_v1_invoice_path(invoice.slug)
  end
end
