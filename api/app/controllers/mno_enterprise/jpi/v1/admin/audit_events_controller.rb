require 'csv'
module MnoEnterprise
  class Jpi::V1::Admin::AuditEventsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/audit_events
    def index
      query = MnoEnterprise::AuditEvent.apply_query_params(params)
      # TODO: Won't scale, call to users and organization will have to be separated
      query.includes(:user, :organization)
      respond_to do |format|
        format.json
          @audit_events = query.to_a
          response.headers['X-Total-Count'] = query.meta.record_count
        format.csv do
          @audit_events = MnoEnterprise::AuditEvent.fetch_all(query)
          headers['Content-Disposition'] = 'attachment; filename="audit-log.csv"'
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    end
  end
end
