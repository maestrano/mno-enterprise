module MnoEnterprise::Concerns::Controllers::ProvisionController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user_or_signup!

    protected
    # The path used after purchased apps have been provisionned
    def after_provision_path
      MnoEnterprise.router.dashboard_path || main_app.root_path
    end

    helper_method :after_provision_path # To use in the provision view
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /provision/new?apps[]=vtiger&organization_id=1
  # TODO: check organization accessibility via ability
  def new
    @apps = params[:apps]
    @organizations = current_user.organizations.to_a
    @organization = @organizations.find { |o| o.id && o.id.to_s == params[:organization_id].to_s }
    unless @organization
      @organization = @organizations.one? ? @organizations.first : nil
    end
    if @organization && cannot?(:manage_app_instances, @organization)
      msg = 'Unfortunately you do not have permission to purchase products for this organization'
      if @organizations.one?
        redirect_path = add_param_to_fragment(after_provision_path.to_s, 'flash', [{msg: msg,  type: :error}.to_json])
        redirect_to redirect_path
      else
        @organization = nil
        flash.now.alert = msg
      end
    end

    # Redirect to dashboard if no applications
    unless @apps && @apps.any?
      redirect_to after_provision_path
    end
  end

  # POST /provision
  # TODO: check organization accessibility via ability
  def create
    # Avoid double provisioning: previous url would be "/provision/new?apps[]=vtiger&organization_id=1"
    session.delete('previous_url')

    @organization = current_user.organizations.find { |o| o.id && o.id.to_s == params[:organization_id].to_s }
    authorize! :manage_app_instances, @organization

    app_instances = []
    params[:apps].each do |product_name|
      app_instance = @organization.provision_app_instance(product_name).first
      app_instances << app_instance
      MnoEnterprise::EventLogger.info('app_add', current_user.id, 'App added', app_instance)
    end

    render json: app_instances.map(&:attributes).to_json, status: :created
  end

end
