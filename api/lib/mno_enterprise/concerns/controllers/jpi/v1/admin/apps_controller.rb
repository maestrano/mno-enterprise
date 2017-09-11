module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::AppsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    FIELDS = [:name, :id, :logo, :nid, :tiny_description]
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/apps
  def index
    query = MnoEnterprise::App.apply_query_params(params).where(scope: 'all').select(*FIELDS)
    @apps = MnoEnterprise::App.fetch_all(query)
    response.headers['X-Total-Count'] = query.meta.record_count
  end

  # PATCH /mnoe/jpi/v1/admin/apps/enable
  # PATCH /mnoe/jpi/v1/admin/apps/:id/enable
  def enable
    # Just proxy it to MnoHub as is
    if params[:id].present?
      MnoEnterprise::App.new(id: params.require(:id)).enable
    elsif params[:ids].present?
      MnoEnterprise::App.enable(ids: params[:ids])
    else
      return render_bad_request('enable apps', 'id or ids required')
    end
    MnoEnterprise::TenantConfig.update_application_list!

    head :ok
  rescue JsonApiClient::Errors::NotFound
    render_not_found('app')
  end

  # PATCH /mnoe/jpi/v1/admin/apps/:id/disable
  def disable
    # Just proxy it to MnoHub as is
    MnoEnterprise::App.new(id: params.require(:id)).disable
    MnoEnterprise::TenantConfig.update_application_list!
    head :ok
  rescue JsonApiClient::Errors::NotFound
    render_not_found('app')
  end
end
