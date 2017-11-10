module MnoEnterprise::Concerns::Controllers::PagesController
  extend ActiveSupport::Concern
  include MnoEnterprise::ImageHelper

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user!, only: [:launch]
    before_filter :redirect_to_lounge_if_unconfirmed, only: [:launch]
    helper_method :main_logo_white_bg_path # To use in the provision view
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /launch/:id
  # Redirect to Mno Enterprise app launcher
  # Launching an app (from dashboard) should redirect to this action
  # The true goal of this action is to hide maestrano in the link behind
  # any dashboard app picture
  #
  # TODO: Access + existence checks could be added in the future. This is not
  # mandatory as Mno Enterprise will do it anyway
  def launch
    app_instance = MnoEnterprise::AppInstance.where(uid: params[:id]).first
    MnoEnterprise::EventLogger.info('app_launch', current_user.id, 'App launched', app_instance)
    redirect_to MnoEnterprise.router.launch_url(params[:id], {wtk: MnoEnterprise.jwt(user_id: current_user.uid)}.reverse_merge(request.query_parameters))
  end

  # GET /loading/:id
  # Loading lounge - wait for an app to be online
  def loading
    @app_instance = MnoEnterprise::AppInstance.where(uid: params[:id]).first

    respond_to do |format|
      format.html { @app_instance_hash = app_instance_hash(@app_instance) }
      format.json { render json: app_instance_hash(@app_instance) }
    end
  end

  # GET /app_access_unauthorized
  def app_access_unauthorized
    @meta[:title] = 'Unauthorized'
    @meta[:description] = 'Application access not granted'
  end

  def billing_details_required
    @meta[:title] = 'Billing Details Required'
    @meta[:description] = 'Billing details have not been provided'
  end

  # GET /app_logout
  def app_logout
    @meta[:title] = 'Logged out'
    @meta[:description] = 'Logged out from application'
  end

  def terms
    @meta[:title] = 'Terms of Use'
    @meta[:description] = 'Terms of Use'
    ts = MnoEnterprise::App.order(updated_at: :desc).select(:updated_at).first.updated_at
    @apps = if ts
              Rails.cache.fetch(['pages/terms/app-list', ts]) do
                # Temp solution as translated fields can not be filtered or sorted
                # MnoEnterprise::App.order_by("name.ac").reject{|i| i.terms_url.blank?}
                MnoEnterprise::App.fetch_all.reject { |i| i.terms_url.blank? }.sort_by{ |a| a.name.downcase }
              end
            else
              []
            end
  end

  private
    def app_instance_hash(app_instance)
      return {} unless app_instance
      {
        id: app_instance.id,
        uid: app_instance.uid,
        name: app_instance.name,
        status: app_instance.status,
        durations: app_instance.durations,
        started_at: app_instance.started_at,
        stopped_at: app_instance.stopped_at,
        created_at: app_instance.created_at,
        server_time: Time.now.utc,
        is_online: app_instance.running?,
        errors: app_instance.errors ? app_instance.errors.full_messages : [],
        logo: app_instance.app.logo
      }
    end

end
