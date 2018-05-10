module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::SubscriptionEventsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_EVENT_INCLUDES ||= [:'subscription', :'subscription.organization', :'subscription.product', :'subscription.product_pricing']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/xyz/subscription_events
  # OR
  # GET /mnoe/jpi/v1/admin/subscription_events
  def index
    # Either fetch a single subscription's #subscription_events or all the #subscription_events of a tenant.
    if params[:organization_id]
      query = fetch_subscription_events(params[:organization_id], params[:subscription_id])
      @subscription_events = query.to_a
    else
      query = MnoEnterprise::SubscriptionEvent.apply_query_params(params).includes(SUBSCRIPTION_EVENT_INCLUDES)
      @subscription_events = query.to_a
    end

    response.headers['X-Total-Count'] = query.meta.record_count
  end

  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/xyz/subscription_events/id
  def show
    @subscription_event = fetch_subscription_event(params[:organization_id], params[:subscription_id], params[:id], SUBSCRIPTION_EVENT_INCLUDES)
    return render_not_found('SubscriptionEvent') unless @subscription_event
  end

  # POST /mnoe/jpi/v1/admin/subscription_events/id/approve
  def approve
    subscription_event = MnoEnterprise::SubscriptionEvent.where(id: params[:id]).first
    return render_not_found('subscription_event') unless subscription_event

    subscription_event.approve!({data: subscription_event.as_json_api})

    head :ok
  end

  # POST /mnoe/jpi/v1/admin/subscription_events/id/reject
  def reject
    subscription_event = MnoEnterprise::SubscriptionEvent.where(id: params[:id]).first
    return render_not_found('subscription_event') unless subscription_event

    subscription_event.reject!({data: subscription_event.as_json_api})

    head :ok
  end

  protected

  def fetch_subscription_events(organization_id, subscription_id)
    MnoEnterprise::SubscriptionEvent
      .apply_query_params(params)
      .with_params(_metadata: { act_as_manager: current_user.id, organization_id: organization_id })
      .includes(SUBSCRIPTION_EVENT_INCLUDES)
      .where('subscription.id' => subscription_id)
  end

  def fetch_subscription_event(organization_id, subscription_id, id, includes = nil)
    rel = MnoEnterprise::SubscriptionEvent
            .with_params(_metadata: { act_as_manager: current_user.id, organization_id: organization_id })
            .where('subscription.id' => subscription_id, id: id)
    rel = rel.includes(*includes) if includes.present?
    rel.first
  end
end
