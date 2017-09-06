json.extract! invoice, :id, :price, :started_at, :ended_at, :created_at, :updated_at, :paid_at, :slug,
              :tax_pips_applied, :billing_address, :total_due, :total_due_remaining

json.organization invoice.organization, :id, :name
