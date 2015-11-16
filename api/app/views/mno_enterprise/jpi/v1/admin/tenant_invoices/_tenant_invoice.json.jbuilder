json.extract! tenant_invoice, :id, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug

if tenant_invoice.paid_at == nil
  json.unpaid true
else
  json.unpaid false
end

json.total_portfolio_amount AccountingjsSerializer.serialize(tenant_invoice.total_portfolio_amount)
json.total_commission_amount AccountingjsSerializer.serialize(tenant_invoice.total_commission_amount)
json.non_commissionable_amount AccountingjsSerializer.serialize(tenant_invoice.non_commissionable_amount)
