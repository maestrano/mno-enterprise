module MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController
  extend ActiveSupport::Concern

  INCLUDED_DEPENDENCIES = %i(organizations orga_relations dashboards teams orga_relations.user orga_relations.organization sub_tenant)

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
    @user = current_user&.load_required(*INCLUDED_DEPENDENCIES) || MnoEnterprise::User.new(id: nil)
  end

  # PUT /mnoe/jpi/v1/current_user
  def update
    current_user.attributes = user_params
    changed_attributes = current_user.changed_attributes
    current_user.save!
    current_user.refresh_user_cache
    MnoEnterprise::EventLogger.info('user_update', current_user.id, 'User update', current_user, changed_attributes)
    @user = current_user.load_required(*INCLUDED_DEPENDENCIES)
    render :show
  end

  # PUT /mnoe/jpi/v1/current_user/register_developer
  def register_developer
    current_user.create_api_credentials!
    MnoEnterprise::EventLogger.info('register_developer', current_user.id, 'Developer registration', current_user)
    @user = current_user.load_required(*INCLUDED_DEPENDENCIES)
    render :show
  end

  # PUT /mnoe/jpi/v1/current_user/update_password
  def update_password
    current_user.update_password!(data: { attributes: password_params })
    MnoEnterprise::EventLogger.info('user_update_password', current_user.id, 'User password change', current_user)
    @user = current_user.load_required(*INCLUDED_DEPENDENCIES)
    sign_in @user, bypass: true
    render :show
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :surname, :email, :company, :phone, :website, :phone_country_code, :current_password, :password, :password_confirmation,
      settings: [:locale]
    )
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_management_enabled?
    return head :forbidden unless Settings.dashboard.user_management.enabled
  end
end
