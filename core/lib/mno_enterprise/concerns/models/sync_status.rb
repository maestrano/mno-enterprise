module MnoEnterprise::Concerns::Models::SyncStatus
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
        status: status,
        app_instance_id: app_instance_id,
        product_instance_id: product_instance_id
      }
    end
end
