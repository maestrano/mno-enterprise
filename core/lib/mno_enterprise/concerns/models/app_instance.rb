module MnoEnterprise::Concerns::Models::AppInstance
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    property :created_at, type: :time
    property :updated_at, type: :time
    property :app_id, type: :string

    # delete <api_root>/app_instances/:id/terminate
    custom_endpoint :terminate, on: :member, request_method: :delete
    custom_endpoint :provision, on: :collection, request_method: :post

    #==============================================================
    # Constants
    #==============================================================
    ACTIVE_STATUSES = [:running, :stopped, :staged, :provisioning, :starting, :stopping, :updating]
    TERMINATION_STATUSES = [:terminating, :terminated]

    has_one :owner
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    def provision!(app_nid, owner_id, owner_type)
      input = { data: { attributes: { app_nid: app_nid, owner_id: owner_id, owner_type: owner_type} } }
      result = provision(input)
      process_custom_result(result)
    end
  end

  def active?
    status.to_sym.in? ACTIVE_STATUSES
  end

  #==================================================================
  # Instance methods
  #==================================================================


  def to_audit_event
    {
      id: id,
      uid: uid,
      name: name,
      app_nid: app_nid,
      organization_id: owner.id
    }
  end

  def terminate!
    result = terminate
    process_custom_result(result)
    result.first
  end

end
