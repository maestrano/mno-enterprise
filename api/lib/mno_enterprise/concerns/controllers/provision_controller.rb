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
    # Redirect to signup page if user not authenticated
    def authenticate_user_or_signup!
      unless current_user
        # if the user does not exist, we start the sign_up process and we transmit the apps to the forms
        # the apps are send as a string because transmitting array parameter to a form does not work
        redirect_to new_user_registration_path(apps:params[:apps].join('+'))
        false
      end
      true
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
    authorize! :manage_app_instances, @organization

    # Redirect to dashboard if no applications
    unless @apps && @apps.any?
      redirect_to after_provision_path
    end
  end

  # POST /provision
  # TODO: check organization accessibility via ability
  def create
    @organization = current_user.organizations.to_a.find { |o| o.id && o.id.to_s == params[:organization_id].to_s }
    authorize! :manage_app_instances, @organization

    app_instances = []
    params[:apps].each do |product_name|
      app_instance = @organization.app_instances.create(product: product_name)
      app_instances << app_instance
      MnoEnterprise::EventLogger.info('app_add', current_user.id, "App added", app_instance.name, app_instance)
    end

    render json: app_instances.map(&:attributes).to_json, status: :created
  end

end
