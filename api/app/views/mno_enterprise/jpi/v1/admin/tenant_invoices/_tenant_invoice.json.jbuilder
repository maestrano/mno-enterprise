json.extract! tenant_invoice, :id, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug

json.total_portfolio_amount AccountingjsSerializer.serialize(tenant_invoice.total_portfolio_amount)
json.total_commission_amount AccountingjsSerializer.serialize(tenant_invoice.total_commission_amount)
json.non_commissionable_amount AccountingjsSerializer.serialize(tenant_invoice.non_commissionable_amount)

