module MnoEnterprise::Concerns::Controllers::Jpi::V1::SubscriptionsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/organizations/1/subscriptions
  def index
    authorize! :manage_app_instances, parent_organization
    @subscriptions = MnoEnterprise::Subscription.includes(:product_instance, :pricing, :contract, :organization, :user, :'license_assignments.user', :'product_instance.product')
                                                .where(organization_id: parent_organization.id)
  end

  # GET /mnoe/jpi/v1/organizations/1/subscriptions/id
  def show
    authorize! :manage_app_instances, parent_organization
    @subscription = MnoEnterprise::Subscription.includes(:product_instance, :pricing, :contract, :organization, :user, :'license_assignments.user', :'product_instance.product')
                                                .where(organization_id: parent_organization.id, id: params[:id]).first
  end

  # POST /mnoe/jpi/v1/organizations/1/subscriptions
  def create
    authorize! :manage_app_instances, parent_organization

    create_params = subscription_update_params.merge(organization_id: parent_organization.id, user_id: current_user.id)
    subscription = MnoEnterprise::Subscription.create(create_params)
    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_add', current_user.id, 'Subscription added', subscription)
      head :created
    end
  end

  # PUT /mnoe/jpi/v1/organizations/1/subscriptions/abc
  def update
    authorize! :manage_app_instances, parent_organization

    subscription = MnoEnterprise::Subscription.where(organization_id: parent_organization.id, id: params[:id]).first
    subscription.update_attributes(subscription_update_params)
    if subscription.errors.any?
      render json: subscription.errors, status: :bad_request
    else
      MnoEnterprise::EventLogger.info('subscription_update', current_user.id, 'Subscription updated', subscription)
      head :ok
    end
  end

  protected

  def subscription_update_params
    params.require(:subscription).permit(:start_date, :max_licenses, :custom_data, :pricing_id, :contract_id)
  end
end
