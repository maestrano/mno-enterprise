json.invoice @invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug,
             :tax_pips_applied, :billing_address
json.organization @invoice.organization
json.bills @invoice.bills
json.billing_summary @invoice.billing_summary
