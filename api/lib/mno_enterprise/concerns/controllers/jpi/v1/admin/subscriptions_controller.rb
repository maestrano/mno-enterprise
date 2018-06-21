module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::SubscriptionsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_INCLUDES ||= [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product']

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/subscriptions
  # or
  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions
  def index
    if params[:terms]
      # Search mode
      @subscriptions = []
      JSON.parse(params[:terms]).map { |t| @subscriptions = @subscriptions | fetch_all_subscriptions.where(Hash[*t]) }
      response.headers['X-Total-Count'] = @subscriptions.count
    else
      query = params[:organization_id].present? ? fetch_subscriptions(params[:organization_id]) : fetch_all_subscriptions
      @subscriptions = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count
    end
  end

  # GET /mnoe/jpi/v1/admin/organizations/1/subscriptions/id
  def show
    set_staged_subscription_params
    @subscription = fetch_subscription(params[:organization_id], params[:id], SUBSCRIPTION_INCLUDES)
    return render_not_found('Subscription') unless @subscription
  end

  # POST /mnoe/jpi/v1/admin/organizations/1/subscriptions
  def create
    # Abort if user does not have access to the organization
    organization = MnoEnterprise::Organization
      .with_params(_metadata: { act_as_manager: current_user.id })
      .select(:id)
      .find(params[:organization_id])
      .first
    return render_not_found('Organization') unless organization

    subscription = MnoEnterprise::Subscription.new(subscription_update_params)
    subscription.status = :staged if cart_subscription_param.present?
    subscription.relationships.organization = organization
    subscription.relationships.user = MnoEnterprise::User.new(id: current_user.id)
    subscription.relationships.product = MnoEnterprise::Product.new(id: params[:subscription][:product_id])
    subscription.save!

    set_staged_subscription_params
    @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)

    MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', subscription) if cart_subscription_param.blank?

    render :show
  end

  # PUT /mnoe/jpi/v1/admin/organizations/1/subscriptions/abc
  def update
    set_staged_subscription_params
    subscription = fetch_subscription(params[:organization_id], params[:id])
    return render_not_found('subscription') unless subscription
    subscription.attributes = subscription_update_params

    edit_action = params[:subscription][:edit_action]
    if cart_subscription_param.present?
      subscription.process_staged_update_request!({data: subscription.as_json_api}, edit_action)
    else
      subscription.save!
    end

    if cancel_staged_subscription_request
      head :no_content
    else
      @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription updated', @subscription, {edit_action: edit_action.to_s}) if cart_subscription_param.blank?
      render :show
    end
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
    subscription_params.permit(:product_contract_id, :product_id).tap do |whitelisted|
      whitelisted[:subscription_events_attributes] = params[:subscription][:subscription_events_attributes]
    end
  end

  def fetch_all_subscriptions
    MnoEnterprise::Subscription
      .apply_query_params(params)
      .with_params(_metadata: { act_as_manager: current_user.id })
      .includes(SUBSCRIPTION_INCLUDES)
  end

  def fetch_subscriptions(organization_id)
    MnoEnterprise::Subscription
      .apply_query_params(params)
      .with_params(_metadata: { act_as_manager: current_user.id })
      .includes(SUBSCRIPTION_INCLUDES)
      .where(organization_id: organization_id)
  end

  def fetch_subscription(organization_id, id, includes = nil)
    rel = MnoEnterprise::Subscription
            .apply_query_params(params)
            .with_params(_metadata: { act_as_manager: current_user.id })
            .where(organization_id: organization_id, id: id)
    rel = rel.includes(*includes) if includes.present?
    rel.first
  end

  def set_staged_subscription_params
    params[:where] ||= {}
    params[:where][:subscription_status_in] = cart_subscription_param.present? ? 'staged' : 'visible'
  end

  def cancel_staged_subscription_request
    params[:subscription][:edit_action] == 'cancel' && cart_subscription_param.present?
  end
end
