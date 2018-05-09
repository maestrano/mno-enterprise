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
    subscription.relationships.organization = organization
    subscription.relationships.user = MnoEnterprise::User.new(id: current_user.id)
    subscription.relationships.product = MnoEnterprise::Product.new(id: params[:subscription][:product_id])
    subscription.relationships.product_pricing = MnoEnterprise::ProductPricing.new(id: params[:subscription][:product_pricing_id])
    subscription.relationships.product_contract = MnoEnterprise::ProductContract.new(id: params[:subscription][:product_contract_id])
    subscription.save!

    MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', subscription)
    @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
    render :show
  end

  # PUT /mnoe/jpi/v1/admin/organizations/1/subscriptions/abc
  def update
    subscription = fetch_subscription(params[:organization_id], params[:id])
    return render_not_found('subscription') unless subscription
    subscription.attributes = subscription_update_params

    edit_action = params[:subscription][:edit_action]
    subscription.proccess_update_request!({data: subscription.as_json_api}, edit_action)

    MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription updated', subscription)
    @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
    render :show
  end

  # POST /mnoe/jpi/v1/admin/organizations/1/subscriptions/abc/cancel
  def cancel
    subscription = fetch_subscription(params[:organization_id], params[:id])
    return render_not_found('subscription') unless subscription
    subscription.cancel!
    MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription cancelled', subscription)
    @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
    render :show
  end

  # POST /mnoe/jpi/v1/admin/organizations/1/subscriptions/abc/approve
  def approve
    subscription = fetch_subscription(params[:organization_id], params[:id])
    return render_not_found('subscription') unless subscription
    subscription.approve!

    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription approved', subscription)
      @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
      render :show
    end
  end

  # POST /mnoe/jpi/v1/admin/organizations/1/subscriptions/abc/fulfill
  def fulfill
    subscription = fetch_subscription(params[:organization_id], params[:id])
    return render_not_found('subscription') unless subscription
    subscription.fulfill!

    MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription fulfilled', subscription)
    @subscription = fetch_subscription(params[:organization_id], subscription.id, SUBSCRIPTION_INCLUDES)
    render :show
  end

  protected

  def subscription_update_params
    # custom_data is an arbitrary hash
    # On Rails 5.1 use `permit(custom_data: {})`
    params.require(:subscription).permit(:start_date, :max_licenses, :custom_data, :product_contract_id, :product_pricing_id).tap do |whitelisted|
      whitelisted[:custom_data] = params[:subscription][:custom_data] if params[:subscription].has_key?(:custom_data) && params[:subscription][:custom_data].is_a?(Hash)
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
            .with_params(_metadata: { act_as_manager: current_user.id })
            .where(organization_id: organization_id, id: id)
    rel = rel.includes(*includes) if includes.present?
    rel.first
  end
end
