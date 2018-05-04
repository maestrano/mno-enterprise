module MnoEnterprise::Concerns::Controllers::Jpi::V1::SubscriptionsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_INCLUDES ||= [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organizations/1/subscriptions
  def index
    authorize! :manage_app_instances, parent_organization
    @subscriptions = fetch_subscriptions(parent_organization.id)
  end

  # GET /mnoe/jpi/v1/organizations/1/subscriptions/id
  def show
    authorize! :manage_app_instances, parent_organization
    @subscription = fetch_subscription(parent_organization.id, params[:id])
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions
  def create
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.new(subscription_update_params)
    subscription.relationships.organization = MnoEnterprise::Organization.new(id: parent_organization.id)
    subscription.relationships.user = MnoEnterprise::User.new(id: current_user.id)
    if params[:subscription][:product_id]
      subscription.relationships.product = MnoEnterprise::Product.new(id: params[:subscription][:product_id])
    end
    if params[:subscription][:product_pricing_id]
      subscription.relationships.product_pricing = MnoEnterprise::ProductPricing.new(id: params[:subscription][:product_pricing_id])
    end
    if params[:subscription][:product_contract_id]
      subscription.relationships.product_contract = MnoEnterprise::ProductContract.new(id: params[:subscription][:product_contract_id])
    end
    subscription.save!

    MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', subscription)
    @subscription = fetch_subscription(parent_organization.id, subscription.id)
    render :show
  end

  # PUT /mnoe/jpi/v1/organizations/1/subscriptions/abc
  def update
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, id: params[:id]).first
    return render_not_found('subscription') unless subscription

    subscription.attributes = subscription_update_params
    subscription.modify!(data: subscription.as_json_api)

    MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription updated', subscription)
    @subscription = fetch_subscription(parent_organization.id, subscription.id)
    render :show
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions/abc/cancel
  def cancel
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, id: params[:id]).first
    return render_not_found('subscription') unless subscription
    subscription.cancel!

    MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription cancelled', subscription)
    @subscription = fetch_subscription(parent_organization.id, subscription.id)
    render :show
  end

  protected

  def subscription_update_params
    # custom_data is an arbitrary hash
    # On Rails 5.1 use `permit(custom_data: {})`
    params.require(:subscription).permit(:start_date, :max_licenses, :product_pricing_id, :product_contract_id, :custom_data).tap do |whitelisted|
      whitelisted[:custom_data] = params[:subscription][:custom_data] if params[:subscription].has_key?(:custom_data) && params[:subscription][:custom_data].is_a?(Hash)
    end
  end

  def fetch_subscriptions(organization_id)
    query = MnoEnterprise::Subscription.with_params(_metadata: { organization_id: organization_id })
    MnoEnterprise::Subscription.fetch_all(query.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id))
  end

  def fetch_subscription(organization_id, id)
    query = MnoEnterprise::Subscription.with_params(_metadata: { organization_id: organization_id })
    query.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id, id: id).first
  end
end
