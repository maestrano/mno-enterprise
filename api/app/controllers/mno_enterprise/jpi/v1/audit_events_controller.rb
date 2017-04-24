module MnoEnterprise
  class Jpi::V1::AuditEventsController < Jpi::V1::BaseResourceController

    # GET /mnoe/jpi/v1/admin/audit_events
    def index
      @organization = MnoEnterprise::Organization.find_one(params.require(:organization_id))

      authorize! :administrate, @organization

      query = MnoEnterprise::AuditEvent.where(organization_id: @organization.id)
      query = MnoEnterprise::AuditEvent.apply_query_params(query, params)

      response.headers['X-Total-Count'] = query.meta.record_count
      @audit_events = query.to_a
      respond_to do |format|
        format.json
        format.csv do
          headers['Content-Disposition'] = 'attachment; filename="audit-log.csv"'
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    end
  end
end
