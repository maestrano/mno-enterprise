module MnoEnterprise::Concerns::Controllers::Webhook::OAuthController
  extend ActiveSupport::Concern
  include MnoEnterprise::ImageHelper

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    before_filter :authenticate_user!, only: [:authorize, :disconnect, :sync]
    before_filter :redirect_to_lounge_if_unconfirmed
    before_filter :check_permissions, only: [:authorize, :disconnect, :sync]

    PROVIDERS_WITH_OPTIONS = ['xero','myob']
    helper_method :main_logo_white_bg # To use in the provision view
    private
      def app_instance
        @app_instance ||= MnoEnterprise::AppInstance.includes(:app).where(uid: params[:id]).first
      end

      # Redirect with an error if user is unauthorized
      def check_permissions
        organization = MnoEnterprise::Organization.find_one(app_instance.owner_id)
        unless can?(:manage_app_instances, organization)
          redirect_to mnoe_home_path, alert: 'You are not authorized to perform this action'
          return false
        end
        true
      end

      # Return a hash of extra parameters that were passed along with
      # the request
      def extra_params
        params.except(:controller,:action,:id, :perform)
      end

      # Current user web token
      def wtk
        MnoEnterprise.jwt(user_id: current_user.uid)
      end

      def error_message(error_key)
        case error_key.to_sym
          when :bad_relinking
            %{A different account '#{app_instance.oauth_company}' was previously linked to this application, please re-link the same account.}
          when :unauthorized
            'We could not validate your credentials, please try again'
          else
            error_key
        end
      end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/webhook/oauth/:id/authorize
  def authorize
    set_session_redirect

    # Certain providers require options to be selected
    if !params[:perform] && app_instance.app && PROVIDERS_WITH_OPTIONS.include?(app_instance.app.nid.to_s)
      render "mno_enterprise/webhook/o_auth/providers/#{app_instance.app.nid}"
      return
    end

    @redirect_to = MnoEnterprise.router.authorize_oauth_url(params[:id], extra_params.merge(wtk: wtk))
  end

  # GET /mnoe/webhook/oauth/:id/callback
  def callback
    path = session.delete(:redirect_path).presence || mnoe_home_path

    if error_key = params.fetch(:oauth, {})[:error]
      path = add_param_to_fragment(path.to_s, 'flash', [{msg: error_message(error_key),  type: :error}.to_json])
    end

    unless params.fetch(:oauth, {})[:error]
      case params.fetch(:oauth, {})[:action]
        when 'sync'
          MnoEnterprise::EventLogger.info('app_connected', current_user.id, 'App connected', app_instance)
        when 'disconnect'
          MnoEnterprise::EventLogger.info('app_disconnected', current_user.id, 'App disconnected', app_instance)
      end
    end

    redirect_to path
  end

  # GET /mnoe/webhook/oauth/:id/disconnect
  def disconnect
    redirect_to MnoEnterprise.router.disconnect_oauth_url(params[:id], extra_params.merge(wtk: wtk))
  end

  # GET /mnoe/webhook/oauth/:id/sync
  def sync
    set_session_redirect
    redirect_to MnoEnterprise.router.sync_oauth_url(params[:id], extra_params.merge(wtk: wtk))
  end

  private

  def set_session_redirect
    if params[:redirect_path].present?
      session[:redirect_path] = params[:redirect_path]
    end
  end

end
