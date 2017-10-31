module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::SubscriptionEventsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_EVENT_INCLUDES ||= [:'subscription']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/subscription_events
  # or
  # GET /mnoe/jpi/v1/admin/organizations/1/subscription_events
  def index
    if params[:terms]
      # Search mode
      @subscription_events = []
      JSON.parse(params[:terms]).map { |t| @subscription_events = @subscription_events | fetch_all_subscriptions.where(Hash[*t]) }
      response.headers['X-Total-Count'] = @subscription_events.count
    else
      query = params[:organization_id].present? ? fetch_subscriptions(params[:organization_id]) : fetch_all_subscriptions
      @subscription_events = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end
  end

  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/id
  def show
    @subscription = fetch_subscription(params[:organization_id], params[:id], SUBSCRIPTION_EVENT_INCLUDES)
    return render_not_found('SubscriptionEvent') unless @subscription
  end

  protected

  def fetch_all_subscription_events
    MnoEnterprise::SubscriptionEvent
      .apply_query_params(params)
      .with_params(_metadata: { act_as_manager: current_user.id })
      .includes(SUBSCRIPTION_EVENT_INCLUDES)
  end

  def fetch_subscription_events(organization_id)
    MnoEnterprise::SubscriptionEvent
      .apply_query_params(params)
      .with_params(_metadata: { act_as_manager: current_user.id })
      .includes(SUBSCRIPTION_EVENT_INCLUDES)
      .where(organization_id: organization_id)
  end

  def fetch_subscription_event(organization_id, id, includes = nil)
    rel = MnoEnterprise::SubscriptionEvent
            .with_params(_metadata: { act_as_manager: current_user.id })
            .where(organization_id: organization_id, id: id)
    rel = rel.includes(*includes) if includes.present?
    rel.first
  end
end
