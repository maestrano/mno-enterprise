module MnoEnterprise::Concerns::Models::AccountTransaction
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    property :created_at, type: :time
    property :updated_at, type: :time
  end

  #==================================================================
  # Class methods
  #==================================================================

  #==================================================================
  # Instance methods
  #==================================================================

  def to_audit_event
    {
      id: id,
      side: side,
      amount_cents: currency,
      currency: currency,
      description: description,
      credit_account_id: credit_account_id
    }
  end
end
