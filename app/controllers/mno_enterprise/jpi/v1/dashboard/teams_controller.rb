class Jpi::V1::Dashboard::TeamsController < Jpi::V1::Dashboard::DashboardController
  respond_to :json
  
  # GET /jpi/v1/dashboard/:organization_id/teams
  def index
    @teams = Org::Team.accessible_by(current_ability).where(organization_id: @organization.id)
  end
  
  # GET /jpi/v1/dashboard/:organization_id/teams/:id
  def show
    @team = Org::Team.find_by_id(params[:id])
    authorize! :read, @team
  end
  
  # POST /jpi/v1/dashboard/:organization_id/teams
  def create
    whitelist = ['name']
    attributes = params[:team].select { |k,v| whitelist.include?(k.to_s) }
    @team = Org::Team.new(attributes.merge(organization: @organization))
    authorize! :create, @team
    
    @team.save
    
    render 'show'
  end
  
  # PUT /jpi/v1/dashboard/:organization_id/teams/:id
  def update
    whitelist = ['name']
    attributes = params[:team].select { |k,v| whitelist.include?(k.to_s) }
    
    @team = Org::Team.find_by_id(params[:id])
    authorize! :update, @team
    
    # Update regular attributes
    @team.update_attributes(attributes)
    
    # Update permissions
    if params[:team] && params[:team][:app_instances]
      id_list = params[:team][:app_instances].map { |h| h[:id] }.compact
      app_instances = @organization.app_instances.where(id: id_list)
      @team.set_access_to(app_instances)
      @team.reload
    end
    
    render 'show'
  end
  
  # PUT /jpi/v1/dashboard/:organization_id/teams/:id/add_users
  def add_users
    @team = Org::Team.find_by_id(params[:id])
    authorize! :edit_users, @team
    
    # Add users
    if params[:team] && params[:team][:users]
      id_list = params[:team][:users].map { |h| h[:id] }.compact
      users = @organization.users.where(id: id_list)
      users.each { |u| @team.add_user(u) }
    end
    
    render 'show'
  end
  
  # PUT /jpi/v1/dashboard/:organization_id/teams/:id/remove_users
  def remove_users
    @team = Org::Team.find_by_id(params[:id])
    authorize! :edit_users, @team
    
    # Add users
    if params[:team] && params[:team][:users]
      id_list = params[:team][:users].map { |h| h[:id] }.compact
      users = @organization.users.where(id: id_list)
      users.each { |u| @team.remove_user(u) }
    end
    
    render 'show'
  end
  
  # DELETE /jpi/v1/dashboard/:organization_id/teams/:id
  def destroy
    @team = Org::Team.find_by_id(params[:id])
    authorize! :destroy, @team
    
    @team.destroy
    
    head :no_content
  end
  
end