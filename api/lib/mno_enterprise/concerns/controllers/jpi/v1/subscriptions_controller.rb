module MnoEnterprise::Concerns::Controllers::Jpi::V1::SubscriptionsController
  extend ActiveSupport::Concern

  SUBSCRIPTION_INCLUDES ||= [:product_instance, :'product_pricing.product', :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product']

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
    subscription.relationships.product_pricing = MnoEnterprise::ProductPricing.new(id: params[:subscription][:product_pricing_id])
    subscription.relationships.product_contract = MnoEnterprise::ProductContract.new(id: params[:subscription][:product_contract_id])
    subscription.save

    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', subscription)
      @subscription = fetch_subscription(parent_organization.id, subscription.id)
      render :show
    end
  end

  # PUT /mnoe/jpi/v1/organizations/1/subscriptions/abc
  def update
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, id: params[:id]).first
    return render_not_found('subscription') unless subscription
    subscription.update_attributes(subscription_update_params)

    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription updated', subscription)
      @subscription = fetch_subscription(parent_organization.id, subscription.id)
      render :show
    end
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions/abc/cancel
  def cancel
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, id: params[:id]).first
    return render_not_found('subscription') unless subscription
    subscription.cancel

    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription cancelled', subscription)
      @subscription = fetch_subscription(parent_organization.id, subscription.id)
      render :show
    end
  end

  protected

  def subscription_update_params
    # custom_data is an arbitrary hash
    # On Rails 5.1 use `permit(custom_data: {})`
    params.require(:subscription).permit(:start_date, :max_licenses, :custom_data).tap do |whitelisted|
      whitelisted[:custom_data] = params[:subscription][:custom_data] if params[:subscription].has_key?(:custom_data) && params[:subscription][:custom_data].is_a?(Hash)
    end
  end

  def fetch_subscriptions(organization_id)
    MnoEnterprise::Subscription.fetch_all(MnoEnterprise::Subscription.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id))
  end

  def fetch_subscription(organization_id, id)
    MnoEnterprise::Subscription.includes(*SUBSCRIPTION_INCLUDES).where(organization_id: organization_id, id: id).first
  end
end
