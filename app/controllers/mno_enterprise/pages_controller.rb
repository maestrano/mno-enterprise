module MnoEnterprise
  class PagesController < ApplicationController
    before_filter :authenticate_user!, only: [:myspace, :launch]
    before_filter :redirect_to_lounge_if_unconfirmed, only: [:myspace, :launch]

    # GET /myspace
    def myspace
      # Meta Information
      @meta[:title] = "Dashboard"
      @meta[:description] = "Dashboard"
      render layout: 'mno_enterprise/application_dashboard'
    end

    # GET /launch/:id
    # Redirect to Mno Enterprise app launcher
    # Launching an app (from dashboard) should redirect to this action
    # The true goal of this action is to hide maestrano in the link behind
    # any dashboard app picture
    #
    # TODO: Access + existence checks could be added in the future. This is not
    # mandatory as Mno Enterprise will do it anyway
    def launch
      redirect_to MnoEnterprise.router.launch_url(params[:id], wtk: MnoEnterprise.jwt(user_id: current_user.uid))
    end

    # GET /loading/:id
    # Loading lounge - wait for an app to be online
    def loading
      @app_instance = MnoEnterprise::AppInstance.where(uid: params[:id]).reload.first

      respond_to do |format|
        format.html { @app_instance_hash = app_instance_hash(@app_instance) }
        format.json { render json: app_instance_hash(@app_instance) }
      end
    end

    # GET /app_access_unauthorized
    def app_access_unauthorized
      @meta[:title] = "Unauthorized"
      @meta[:description] = "Application access not granted"
    end

    def billing_details_required
      @meta[:title] = "Billing Details Required"
      @meta[:description] = "Billing details have not been provided"
    end

    # GET /app_logout
    def app_logout
      @meta[:title] = "Logged out"
      @meta[:description] = "Logged out from application"
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
          is_online: app_instance.online?,
          errors: app_instance.errors ? app_instance.errors.full_messages : [],
        }
      end
  end
end
