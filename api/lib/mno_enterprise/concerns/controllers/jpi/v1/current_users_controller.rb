module MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user!, only: [:update, :update_password]
    before_filter :user_management_enabled?, only: [:update, :update_password]
    respond_to :json
  end


  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/current_user
  def show
    @user = current_user || MnoEnterprise::User.new(id: nil)
  end

  # PUT /mnoe/jpi/v1/current_user
  def update
    @user = current_user
    @user.attributes = user_params
    changed_attributes = @user.changed_attributes
    @user.save
    if @user.errors.empty?
      MnoEnterprise::EventLogger.info('user_update', current_user.id, 'User update', @user, changed_attributes)
      @user = @user.load_required_dependencies
      render :show
    else
      render json: @user.errors, status: :bad_request
    end
    current_user.refresh_user_cache
  end

  # PUT /mnoe/jpi/v1/current_user/register_developer
  def register_developer
    @user = current_user
    @user = @user.create_api_credentials.first
    if @user.errors.empty?
      MnoEnterprise::EventLogger.info('register_developer', current_user.id, 'Developer registration', @user)
      @user = @user.load_required_dependencies
      render :show
    else
      render json: @user.errors, status: :bad_request
    end
  end

  # PUT /mnoe/jpi/v1/current_user/update_password
  def update_password
    @user = current_user
    @user = @user.update_password(data: {attributes: password_params}).first
    # TODO: [APIv2] This is not working!
    # update_password returns an empty array in case of error
    if @user.errors.empty?
      MnoEnterprise::EventLogger.info('user_update_password', current_user.id, 'User password change', @user)
      @user = @user.load_required_dependencies
      sign_in @user, bypass: true
      render :show
    else
      render json: @user.errors, status: :bad_request
    end
  end

  private
  
    def user_params
      params.require(:user).permit(
        :name, :surname, :email, :company, :phone, :website, :phone_country_code, :current_password, :password, :password_confirmation,
        settings: [:locale, :default_dashboard_currency, currencies: []]
      )
    end

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end

    def user_management_enabled?
      return head :forbidden unless Settings.dashboard.user_management.enabled
    end
end
