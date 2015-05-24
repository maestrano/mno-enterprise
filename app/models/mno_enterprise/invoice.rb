# == Schema Information
#
# Endpoint:
#  - /v1/invoices
#  - /v1/organizations/:organization_id/invoices
#
#  id                     :integer         not null, primary key
#  price_cents            :integer
#  currency               :string(255)
#  invoicable_type        :string(255)
#  invoicable_id          :integer
#  started_at             :datetime
#  ended_at               :datetime
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  paid_at                :datetime
#  pdf                    :string(255)
#  payment_id             :integer
#  transferred_from_id    :integer
#  transferred_from_type  :string(255)
#  transferred_at         :datetime
#  account_transaction_id :integer
#  resolver_invoice_id    :integer
#  resolving_invoice_id   :integer
#  slug                   :string(255)
#  promo_voucher_id       :integer
#  tax_pips_applied       :integer
#  billing_address        :text
#  partner_invoice_id     :integer
#  mnoe_tenant_id         :integer
#

module MnoEnterprise
  class Invoice < BaseResource
    #==============================================================
    # Associations
    #==============================================================
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
    
    # Return a label describing the time period
    # this invoice covers
    def period_label
      return '' unless self.started_at && self.ended_at
      "#{self.started_at.strftime("%b %d,%Y")} to #{self.ended_at.strftime("%b %d,%Y")}"
    end
    
    # Return true if the invoice has been paid
    # false otherwise
    def paid?
      !self.paid_at.blank?
    end
  end
end
