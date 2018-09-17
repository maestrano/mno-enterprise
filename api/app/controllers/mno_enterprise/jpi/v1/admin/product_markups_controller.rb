module MnoEnterprise
  class Jpi::V1::Admin::ProductMarkupsController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:product, :'product.product_pricings', :organization]

    # Overwrite check support authorization for index action only.
    skip_before_action :block_support_users, only: [:index]
    before_filter :authorize_support_product_markups, only: [:index], if: -> { current_user.support? }

    # GET /mnoe/jpi/v1/admin/product_markups
    def index
      if params[:terms]
        # Search mode
        @product_markups = []

        # Don't separate terms to build an AND close, and not a OR
        @product_markups = MnoEnterprise::ProductMarkup.with_params(_metadata: special_roles_metadata).includes(DEPENDENCIES).where(JSON.parse(params[:terms]))
        response.headers['X-Total-Count'] = @product_markups.count
      else
        # Index mode
        query = MnoEnterprise::ProductMarkup.apply_query_params(params).with_params(_metadata: special_roles_metadata).includes(DEPENDENCIES)
        @product_markups = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/product_markups/1
    def show
      @product_markup = MnoEnterprise::ProductMarkup.with_params(_metadata: special_roles_metadata).includes(:product,:organization).find(params[:id]).first
    end

    # POST /mnoe/jpi/v1/admin/product_markups
    def create
      @product_markup = MnoEnterprise::ProductMarkup.new(product_markups_params)
      @product_markup.relationships.product = MnoEnterprise::Product.new(id: product_markups_create_params[:product_id])
      @product_markup.relationships.organization = MnoEnterprise::Organization.new(id: product_markups_create_params[:organization_id])
      @product_markup.save!

      render :show
    end

    # PATCH /mnoe/jpi/v1/admin/product_markups/:id
    def update
      @product_markup = MnoEnterprise::ProductMarkup.find_one(params[:id])
      @product_markup.update!(product_markups_params)
      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/product_markups/1
    def destroy
      product_markups = MnoEnterprise::ProductMarkup.find_one(params[:id])
      product_markups.destroy!
      head :no_content
    end

    private

    def product_markups_create_params
      attrs = [:percentage, :product_id, :organization_id]
      params.require(:product_markup).permit(attrs)
    end

    def product_markups_params
      attrs = [:percentage]
      params.require(:product_markup).permit(attrs)
    end

    def authorize_support_product_markups
      # Organization id comes in special parameters, as mnohub must also fetch tenant-wide markups.
      organization_id = params.dig('where', 'for_organization')
      if organization_id
        authorize! :read, MnoEnterprise::Organization.new(id: organization_id)
      # Support users can only see certain organization specific markups based on their session.
      else
        render nothing: true, status: :forbidden
      end
    end
  end
end
