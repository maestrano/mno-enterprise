module MnoEnterprise
  class Jpi::V1::Admin::AuditEventsController < Jpi::V1::Admin::BaseResourceController
    
    # GET /mnoe/jpi/v1/admin/audit_events
    def index
      @audit_events = MnoEnterprise::AuditEvent
      @audit_events = @audit_events.limit(params[:limit]) if params[:limit]
      @audit_events = @audit_events.skip(params[:offset]) if params[:offset]
      @audit_events = @audit_events.order_by(params[:order_by]) if params[:order_by]
      @audit_events = @audit_events.where(params[:where]) if params[:where]
      @audit_events = @audit_events.all

      response.headers['X-Total-Count'] = @audit_events.metadata[:pagination][:count]
    end
  end
end
