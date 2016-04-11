module MnoEnterprise
  class Jpi::V1::Admin::OrganizationsController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/organizations
    def index
      if params[:terms]
        # Search mode
        @organizations = []
        JSON.parse(params[:terms]).map { |t| @organizations = @organizations | MnoEnterprise::Organization.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @organizations.count
      else
        # Index mode
        @organizations = MnoEnterprise::Organization
        @organizations = @organizations.limit(params[:limit]) if params[:limit]
        @organizations = @organizations.skip(params[:offset]) if params[:offset]
        @organizations = @organizations.order_by(params[:order_by]) if params[:order_by]
        @organizations = @organizations.where(params[:where]) if params[:where]
        @organizations = @organizations.all
        response.headers['X-Total-Count'] = @organizations.metadata[:pagination][:count]
      end
    end

    # GET /mnoe/jpi/v1/admin/organizations/1
    def show
      @organization = MnoEnterprise::Organization.find(params[:id])
      @organization_active_apps = @organization.app_instances.select { |app| app.status == "running" }
    end

    # GET /mnoe/jpi/v1/admin/organizations/in_arrears
    def in_arrears
      @arrears = MnoEnterprise::ArrearsSituation.all
    end

    # GET /mnoe/jpi/v1/admin/organizations/count
    def count
      organizations_count = MnoEnterprise::Tenant.get('tenant').organizations_count
      render json: {count: organizations_count }
    end

    # POST /mnoe/jpi/v1/admin/organizations
    def create
      # Create new organization
      @organization = MnoEnterprise::Organization.create(organization_update_params)

      # OPTIMIZE: move this into a delayed job?
      update_app_list

      @organization_active_apps = @organization.app_instances

      render 'show'
    end

    protected
      def organization_permitted_update_params
        [:name, :app_nids]
      end

      def organization_update_params
        params.fetch(:organization, {}).permit(*organization_permitted_update_params)
      end

      # Update App List to match the list passed in params
      def update_app_list
        # Differentiate between a null app_nids params and no app_nids params
        if params[:organization].key?(:app_nids) && (desired_nids = Array(params[:organization][:app_nids]))

          existing_apps = @organization.app_instances.active

          existing_apps.each do |app_instance|
            desired_nids.delete(app_instance.app.nid) || app_instance.terminate
          end

          desired_nids.each do |nid|
            @organization.app_instances.create(product: nid)
          end

          # Force reload
          existing_apps.reload
        end
      end
  end
end
