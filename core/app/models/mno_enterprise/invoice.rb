module MnoEnterprise
  class Invoice < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :paid_at, type: :time
    property :organization_id

    has_many :bills
    has_one :organization

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

    # Will the organization be deleted after this invoice ?
    def will_org_be_deleted?
      self.organization.account_frozen && !self.organization.frozen_at.nil? && self.organization.frozen_at < self.ended_at
    end
  end
end
