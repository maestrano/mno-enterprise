json.invoices do
  json.array! organization.invoices.sort_by(&:ended_at).reverse do |invoice|
    json.started_at invoice.started_at
    json.ended_at invoice.ended_at
    json.amount AccountingjsSerializer.serialize(invoice.total_due)
    json.paid invoice.paid?
    json.link mno_enterprise.admin_invoice_path(invoice.slug)
  end
end
