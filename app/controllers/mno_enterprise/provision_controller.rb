module MnoEnterprise
  class ProvisionController < ApplicationController
    before_filter :authenticate_user_or_signup!
    
    # GET /provision/new
    # TODO: check organization accessibility via ability
    def new
      @apps = params[:apps]
      @organizations = current_user.organizations.to_a
      @organization = @organizations.find { |o| o.id && o.id.to_s == params[:organization_id].to_s }
      
      unless @organization
        @organization = @organizations.one? ? @organizations.first : nil
      end
      
      # Redirect to dashboard if no applications
      unless @apps && @apps.any?
        redirect_to myspace_path
      end
    end
    
    # POST /provision
    # TODO: check organization accessibility via ability
    def create
      @organization = current_user.organizations.to_a.find { |o| o.id && o.id.to_s == params[:organization_id].to_s }
      
      app_instances = []
      params[:apps].each do |product_name|
        app_instances << @organization.app_instances.create(product: product_name)
      end
      
      head :created
    end
      
  end
end