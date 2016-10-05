# This controller is used to handle the authentication (+creation) of external
# users via OpenID (e.g: QuickBooks OpenID)
#
# When users click on the "sign in with <provider>" button, they get redirected
# to the authorize endpoint (/users/auth/:provider - e.g: /users/auth/intuit).
# The action (handled by parent controller OmniauthCallbacksController) prepares
# the callback url then redirects the user to the OpenID provider (E.g: Intuit)
# for authentication.
#
# Once authentication has been performed at the OpenID provider level (e.g: Intuit)
# the user gets redirected to the callback endpoint (/users/auth/:provider/callback)
# The provider parameter in the url (E.g: intuit) gets automatically redirected to a
# controller action with the same name (handled by parent controller OmniauthCallbacksController)
# as you can see below with intuit.
#
# Then provider specific action then handles the (creation +) authentication of the user.
# Also, it automatically adds the right applications to the user dashboard (e.g: QuickBooks for
# Intuit)
#
# Intuit:
# --------
# For intuit, the authorize endpoint is be bypassed when the user clicks "try Maestrano" from
# the Intuit marketplace. The user automatically lands on the callback endpoints with a parameter
# in the url called 'qb_initiated'. This parameter is used to automatically trigger the retrieval
# of the oauth token in the background via javascript (by storing the temporary grant url in session)
#
# On Intuit, it is also possible to directly choose one of the apps proposed by Maestrano (E.g: 'SugarCRM
# by Maestrano'). In this case, an 'app' attribute containing the app nid (named id - e.g: 'sugarcrm') is
# added to the url parameters. The action then setup the app automatically (along with QuickBooks).
#
#
module MnoEnterprise::Concerns::Controllers::Auth::OmniauthCallbacksController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  included do
    skip_filter :verify_authenticity_token, only: [:intuit]

    providers = Devise.omniauth_providers & %i(linkedin google facebook)

    providers.each do |provider|
      provides_callback_for provider
    end
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    def provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = env["omniauth.auth"]
          opts = { orga_on_create: create_orga_on_user_creation(auth.info.email) }

          @user = MnoEnterprise::User.find_for_oauth(auth, opts, current_user)

          if @user.persisted?
            sign_in_and_redirect @user, event: :authentication
            set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
          else
            session["devise.#{provider}_data"] = env["omniauth.auth"]
            redirect_to new_user_registration_url
          end
        end
      }
    end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET|POST /users/auth/:action/callback
  def intuit
    auth = request.env['omniauth.auth']
    opts = {
      orga_on_create: create_orga_on_user_creation(auth.info.email),
      authorized_link_to_email: session['omniauth.intuit.authorized_link_to_email']
    }

    # Try to find via intuit
    begin
      @user = MnoEnterprise::User.find_for_oauth(auth, opts, current_user)
    rescue SecurityError
      # Intuit email is NOT a confirmed email. Therefore we need to ask the user to
      # login the old fashion to make sure it is the right user!
      session["omniauth.intuit.request_account_link"] = true
      redirect_to new_user_session_path, notice: "Please sign in using your regular Maestrano account to confirm that you want to link it to your Intuit account"
      return
    end

    # Cleanup any temporary omniauth.intuit session
    cleanup_intuit_session

    if @user && @user.persisted?
      # Automatically adds a QuickBooks app (and any other app passed via :app param)
      # to the user orga
      # Only for new users for which an orga was created (not an invited user
      # typically)
      app_instances = setup_apps(@user,['quickbooks',params[:app]], oauth_keyset: params[:app])
      qb_instance = app_instances.first

      # On Intuit, Mno is configured to add qb_initiated=true if the user
      # comes directly from apps.com (This is a different workflow from using
      # the QuickBooks connect button because we're supposed to trigger the
      # oauth workflow directly via javascript using directConnectToIntuit)
      # Here we store in session the fact that we need to trigger an oauth
      # workflow via directConnectToIntuit
      # ----
      # See layouts/partners/intuit for more info. The session param set
      # below get reset in the view.
      #
      if params[:qb_initiated] && qb_instance && !qb_instance.oauth_keys_valid?
        session[:qb_direct_connect_grant_url] = authorize_webhook_oauth_url(qb_instance.uid)
      end

      # The above methods trigger many different hooks which
      # may impact the user (typically user workspace). It is safer
      # to reload the user before continuing so that the picture
      # is up to date
      @user.reload

      # Check whether we should redirect the user to a specific
      # url
      redirect_url = session.delete(:openid_previous_url) || MnoEnterprise.router.dashboard_path || main_app.root_path

      sign_in @user
      redirect_to redirect_url, event: :authentication

      set_flash_message(:notice, :success, kind: "Intuit") if is_navigational_format?
    else
      session["devise.intuit_data"] = request.env["omniauth.auth"]
      redirect_to home_url, "ng-controller" => "MnoSignupProcessCtrl", "ng-click" => "startProcess()"
    end
  end

  #================================================
  # Private methods
  #================================================
  private

    def cleanup_intuit_session
      session.delete("omniauth.intuit.passthru_email")
      session.delete("omniauth.intuit.request_account_link")
    end

    # Whether to create an orga on user creation
    def create_orga_on_user_creation(user_email = nil)
      return false if user_email.blank?
      return false if MnoEnterprise::User.exists?(email: user_email)

      # First check previous url to see if the user
      # was trying to accept an orga
      if !session[:previous_url].blank? && (r = session[:previous_url].match(/\/orga_invites\/(\d+)\?token=(\w+)/))
        invite_params = { id: r.captures[0].to_i, token: r.captures[1] }
        return false if OrgInvite.where(invite_params).any?
      end

      # Get remaining invites via email address
      return MnoEnterprise::OrgInvite.where(user_email: user_email).empty?
    end

    # Create or find the apps provided in argument
    # Accept an array of app nid (named id - e.g: 'quickbooks')
    # opts:
    #   oauth_keyset: If a oauth_keyset is provided then it will be added to the
    # oauth_keys of any app that is oauth ready (QuickBooks for example)
    #
    # Return an array of app instances (found or created)
    def setup_apps(user = nil, app_nids = [], opts = {})
      return [] unless user
      return [] unless (user.organizations.reload.count == 1)
      return [] unless (org = user.organizations.first)
      return [] unless MnoEnterprise::Ability.new(user).can?(:edit,org)

      results = []

      apps = MnoEnterprise::App.where(nid: app_nids.compact)
      existing = org.app_instances.active.index_by(&:app_id)

      # For each app nid (which is not nil), try to find an existing instance or create one
      apps.each do |app|
        if (instance = existing[app.id])
          results << instance
        else
          # Provision instance and add to results
          instance = org.app_instances.create(product: app.nid)
          results << instance
          MnoEnterprise::EventLogger.info('app_add', user.id, "App added", instance.name, instance)
        end

        # Add oauth keyset if defined and app_instance is
        # oauth ready and does not have a valid set of oauth keys
        if instance && opts[:oauth_keyset].present? && !instance.oauth_keys_valid?
          instance.oauth_keys = { keyset: opts[:oauth_keyset] }
          instance.save
        end
      end
      return results
    end
end
