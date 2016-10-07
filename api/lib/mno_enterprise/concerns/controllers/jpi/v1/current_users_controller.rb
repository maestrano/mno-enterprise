module MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end


  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/current_user
  def show
    @user = current_user || MnoEnterprise::User.new
  end

  # PUT /mnoe/jpi/v1/current_user
  def update
    @user = current_user

    @user.assign_attributes(user_params)
    changes = @user.changes
    if @user.update(user_params)
      MnoEnterprise::EventLogger.info('user_update', current_user.id, "User update", changes, @user)
      render :show
    else
      render json: @user.errors, status: :bad_request
    end
  end

  # PUT /mnoe/jpi/v1/current_user/update_password
  def update_password
    @user = current_user

    if @user.update(password_params.merge(current_password_required: true))
      MnoEnterprise::EventLogger.info('user_update_password', current_user.id, "User password change", @user.email, @user)
      sign_in @user, bypass: true
      render :show
    else
      render json: @user.errors, status: :bad_request
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :surname, :email, :company, :settings, :phone, :website, :phone_country_code, :current_password, :password, :password_confirmation)
    end

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
end
