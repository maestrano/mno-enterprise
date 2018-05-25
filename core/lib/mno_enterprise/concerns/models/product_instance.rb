module MnoEnterprise::Concerns::Models::ProductInstance
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    property :created_at, type: :time
    property :updated_at, type: :time

    #==============================================================
    # Constants
    #==============================================================
    ACTIVE_STATUSES = [:running]
    TERMINATION_STATUSES = [:terminating, :terminated]
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
        status: status,
        organization_id: organization_id
      }
    end
end
