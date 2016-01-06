module MnoEnterprise
  class Jpi::V1::Admin::AuditEventsController < Jpi::V1::Admin::BaseResourceController
    
    # GET /mnoe/jpi/v1/admin/audit_events
    def index
      if params[:top] || params[:skip]
        @audit_events = MnoEnterprise::AuditEvent.limit(params[:top]).skip(params[:skip]).all
      else
        @audit_events = MnoEnterprise::AuditEvent.all
      end
    end
  end
end
