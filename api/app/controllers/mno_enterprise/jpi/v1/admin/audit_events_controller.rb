module MnoEnterprise
  class Jpi::V1::Admin::AuditEventsController < Jpi::V1::Admin::BaseResourceController
    # GET /mnoe/jpi/v1/admin/audit_events
    def index
      @audit_events = MnoEnterprise::AuditEvent.all.to_a
    end
  end
end
