module MnoEnterprise::Concerns::Controllers::Jpi::V1::SubscriptionEventsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_EVENT_INCLUDES ||= [:'subscription']

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

  protected

  def fetch_subscription_events(organization_id, subscription_id)
    query = MnoEnterprise::SubscriptionEvent.with_params(_metadata: { organization_id: organization_id })
    MnoEnterprise::SubscriptionEvent.fetch_all(query.includes(*SUBSCRIPTION_EVENT_INCLUDES).where('subscription.id' => subscription_id))
  end

  def fetch_subscription_event(organization_id, subscription_id, id)
    query = MnoEnterprise::SubscriptionEvent.with_params(_metadata: { organization_id: organization_id })
    query.includes(*SUBSCRIPTION_EVENT_INCLUDES).where('subscription.id' => subscription_id, id: id).first
  end
end
