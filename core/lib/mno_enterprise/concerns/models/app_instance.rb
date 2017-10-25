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

    property :owner_id, type: :string

    # delete <api_root>/app_instances/:id/terminate
    custom_endpoint :terminate, on: :member, request_method: :delete
    custom_endpoint :provision, on: :collection, request_method: :post
    custom_endpoint :sync_history, on: :member, request_method: :get
    custom_endpoint :id_maps, on: :member, request_method: :get

    #==============================================================
    # Constants
    #==============================================================
    ACTIVE_STATUSES = [:running, :stopped, :staged, :provisioning, :starting, :stopping, :updating]
    TERMINATION_STATUSES = [:terminating, :terminated]
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
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
      organization_id: owner_id
    }
  end
end
