module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::SubscriptionEventsController
  extend ActiveSupport::Concern

  included do
    SUBSCRIPTION_EVENT_INCLUDES ||= [:'subscription', :'subscription.organization', :'subscription.product', :'product_pricing']

    # Workaround because using only and if are not possible (it checks to see if either satisfy, not both.)
    # https://github.com/rails/rails/issues/9703#issuecomment-223574827
    skip_before_filter :block_support_users, if: :authorize_support?
    before_filter :authorize_support_user_organization, if: :authorize_support?
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/xyz/subscription_events or
  # GET /mnoe/jpi/v1/admin/organizations/1/subscription_events or
  # GET /mnoe/jpi/v1/admin/subscription_events
  def index
    # Fetch only the subscription events of a subscription
    if params[:subscription_id]
      query = fetch_subscription_events(organization_id: params[:organization_id], subscription_id: params[:subscription_id])

    # Fetch all the subscription events of an organization
    elsif params[:organization_id]
      org = MnoEnterprise::Organization
              .with_params(_metadata: special_roles_metadata)
              .includes([:subscriptions])
              .find(params[:organization_id]).first

      #Find organization's subscription_ids
      query = fetch_subscription_events(subscription_id: org.subscriptions.map(&:id))

    # Fetch all the subscription events of a tenant
    else
      query = fetch_subscription_events()
    end

    @subscription_events = query.to_a
    response.headers['X-Total-Count'] = query.meta.record_count
  end

  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/xyz/subscription_events/id
  def show
    @subscription_event = fetch_subscription_event(params[:organization_id], params[:subscription_id], params[:id], SUBSCRIPTION_EVENT_INCLUDES)
    return render_not_found('SubscriptionEvent') unless @subscription_event
  end

  # POST /mnoe/jpi/v1/admin/organizations/1/subscriptions/xyz/subscription_events
  def create
    subscription_event = MnoEnterprise::SubscriptionEvent.new(subscription_event_params)
    subscription_event.relationships.subscription = MnoEnterprise::Subscription.new(id: params[:subscription_id])
    if params[:subscription_event][:product_pricing_id]
      subscription_event.relationships.product_pricing = MnoEnterprise::ProductPricing.new(id: params[:subscription_event][:product_pricing_id])
    end

    subscription_event.save!
    # Fetch so that we can include relationships.
    @subscription_event = fetch_subscription_event(params[:organization_id], params[:subscription_id], subscription_event.id, SUBSCRIPTION_EVENT_INCLUDES)
    render :show
  end

  # POST /mnoe/jpi/v1/admin/subscription_events/id/approve
  def approve
    subscription_event = MnoEnterprise::SubscriptionEvent.where(id: params[:id]).first
    return render_not_found('subscription_event') unless subscription_event

    subscription_event.approve!({data: subscription_event.as_json_api})

    MnoEnterprise::EventLogger.info('subscription_approved', current_user.id, 'Subscription update', subscription_event, {edit_action: subscription_event.event_type.to_s})

    head :ok
  end

  # POST /mnoe/jpi/v1/admin/subscription_events/id/reject
  def reject
    subscription_event = MnoEnterprise::SubscriptionEvent.where(id: params[:id]).first
    return render_not_found('subscription_event') unless subscription_event

    subscription_event.reject!({data: subscription_event.as_json_api})

    MnoEnterprise::EventLogger.info('subscription_rejected', current_user.id, 'Subscription update', subscription_event, {edit_action: subscription_event.event_type.to_s})

    head :ok
  end

  protected

  def subscription_event_params
    params.require(:subscription_event).permit(:event_type).tap do |whitelisted|
      whitelisted[:subscription_details] = params[:subscription_event][:subscription_details]
    end
  end

  def fetch_subscription_events(organization_id: nil, subscription_id: nil)
    rel = MnoEnterprise::SubscriptionEvent
            .apply_query_params(params)
            .with_params(_metadata: subscription_metadata(organization_id))
            .includes(SUBSCRIPTION_EVENT_INCLUDES)

    rel = rel.where('subscription.id' => subscription_id.presence) if subscription_id

    rel
  end

  def fetch_subscription_event(organization_id, subscription_id, id, includes = nil)
    rel = MnoEnterprise::SubscriptionEvent
            .with_params(_metadata: subscription_metadata(organization_id))
            .where('subscription.id' => subscription_id, id: id)
    rel = rel.includes(*includes) if includes.present?
    rel.first
  end

  def subscription_metadata(organization_id = nil)
    metadata = special_roles_metadata
    metadata[:organization_id] = organization_id if organization_id
    metadata
  end

  def authorize_support?
    support_org_params && ['show', 'index'].include?(action_name)
  end
end
