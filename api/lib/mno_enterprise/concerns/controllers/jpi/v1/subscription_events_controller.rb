module MnoEnterprise::Concerns::Controllers::Jpi::V1::SubscriptionEventsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_EVENT_INCLUDES ||= [:subscription]

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organizations/1/subscriptions/xyz/subscription_events
  def index
    authorize! :manage_app_instances, parent_organization
    @subscription_events = fetch_subscription_events(parent_organization.id, params[:subscription_id])
  end

  # GET /mnoe/jpi/v1/organizations/1/subscriptions/xyz/subscription_events/id
  def show
    authorize! :manage_app_instances, parent_organization
    @subscription_event = fetch_subscription_event(parent_organization.id, params[:subscription_id], params[:id])
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions/xyz/subscription_events/id
  def create
    subscription_event = MnoEnterprise::SubscriptionEvent.new(subscription_event_params)
    subscription_event.relationships.subscription = MnoEnterprise::Subscription.new(id: params[:subscription_id])
    if params[:subscription_event][:product_pricing_id]
      subscription_event.relationships.product_pricing = MnoEnterprise::ProductPricing.new(id: params[:subscription_event][:product_pricing_id])
    end

    subscription_event.save!
    # Fetch so that we can include relationships.
    @subscription_event = fetch_subscription_event(params[:organization_id], params[:subscription_id], subscription_event.id)
    render :show
  end

  protected

  def fetch_subscription_events(organization_id, subscription_id)
    query = MnoEnterprise::SubscriptionEvent.apply_query_params(params).with_params(_metadata: { organization_id: organization_id })
    MnoEnterprise::SubscriptionEvent.fetch_all(query.includes(*SUBSCRIPTION_EVENT_INCLUDES).where('subscription.id' => subscription_id))
  end

  def fetch_subscription_event(organization_id, subscription_id, id)
    query = MnoEnterprise::SubscriptionEvent.with_params(_metadata: { organization_id: organization_id })
    query.includes(*SUBSCRIPTION_EVENT_INCLUDES).where('subscription.id' => subscription_id, id: id).first
  end

  def subscription_event_params
    params.require(:subscription_event).permit(:event_type).tap do |whitelisted|
      whitelisted[:subscription_details] = params[:subscription_event][:subscription_details]
    end
  end
end
