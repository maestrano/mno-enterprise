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
    subscription.status = :staged if cart_subscription_param.present?
    subscription.relationships.organization = MnoEnterprise::Organization.new(id: parent_organization.id)
    subscription.relationships.user = MnoEnterprise::User.new(id: current_user.id)
    if params[:subscription][:product_id]
      subscription.relationships.product = MnoEnterprise::Product.new(id: params[:subscription][:product_id])
    end
    subscription.save!

    @subscription = fetch_subscription(parent_organization.id, subscription.id)

    MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', @subscription) if cart_subscription_param.blank?

    render :show
  end

  # PUT /mnoe/jpi/v1/organizations/1/subscriptions/abc
  def update
    authorize! :manage_app_instances, parent_organization

    status_params = { organization_id: parent_organization.id, id: params[:id] }
    status_params[:subscription_status_in] = 'staged' if cart_subscription_param.present?
    subscription = MnoEnterprise::Subscription.where(status_params).first
    return render_not_found('subscription') unless subscription

    subscription.attributes = subscription_update_params
    edit_action = params[:subscription][:edit_action]
    if cart_subscription_param.present?
      subscription.process_staged_update_request!({data: subscription.as_json_api}, edit_action)
    else
      subscription.process_update_request!({data: subscription.as_json_api}, edit_action)
    end

    if cancel_staged_subscription_request
      head :no_content
    else
      @subscription = fetch_subscription(parent_organization.id, subscription.id)
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription update', @subscription, {edit_action: edit_action.to_s}) if cart_subscription_param.blank?
      render :show
    end
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions/abc/cancel
  def cancel
    authorize! :manage_app_instances, parent_organization

    status_params = { organization_id: parent_organization.id, id: params[:id] }
    status_params[:subscription_status_in] = 'staged' if cart_subscription_param.present?
    subscription = MnoEnterprise::Subscription.where(status_params).first
    return render_not_found('subscription') unless subscription
    if cart_subscription_param.present?
      subscription.abandon!
      head :no_content
    else
      subscription.cancel!
      @subscription = fetch_subscription(parent_organization.id, subscription.id)
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription cancelled', @subscription)
      render :show
    end
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions/cancel_cart_subscriptions
  def cancel_cart_subscriptions
    authorize! :manage_app_instances, parent_organization
    MnoEnterprise::Subscription.cancel_staged(organization_id: parent_organization.id)

    head :no_content
  end


  # POST /mnoe/jpi/v1/organizations/1/subscriptions/submit_cart_subscriptions
  def submit_cart_subscriptions
    authorize! :manage_app_instances, parent_organization

    subscriptions = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, status: :staged).to_a
    MnoEnterprise::Subscription.submit_staged(organization_id: parent_organization.id)

    subscriptions.each do |sub|
      MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', sub)
    end
    head :no_content
  end

  protected

  def cart_subscription_param
    params.dig(:subscription, :cart_entry)
  end

  def subscription_params
    params.require(:subscription)
  end

  def subscription_update_params
    # custom_data is an arbitrary hash
    subscription_params.permit(:start_date, :product_contract_id, :product_pricing_id, :product_id).tap do |whitelisted|
      whitelisted[:subscription_events_attributes] = params[:subscription][:subscription_events_attributes]
    end
  end

  def fetch_subscriptions(organization_id)
    filter_params = JSON.parse(params[:where]) || {} rescue {}
    query = MnoEnterprise::Subscription.with_params(_metadata: { organization_id: organization_id })
    MnoEnterprise::Subscription.fetch_all(query.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id).where(filter_params))
  end

  def fetch_subscription(organization_id, id)
    status_params = { subscription_status_in: cart_subscription_param.present? ? 'staged' : 'visible' }
    query = MnoEnterprise::Subscription.with_params(_metadata: { organization_id: organization_id })
    query.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id, id: id).where(status_params).first
  end

  def cancel_staged_subscription_request
    params[:subscription][:edit_action] == 'cancel' && cart_subscription_param.present?
  end
end
