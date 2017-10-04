module MnoEnterprise
  class Jpi::V1::Admin::ProductMarkupsController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:product, :organization]

    # GET /mnoe/jpi/v1/admin/product_markups
    def index
      if params[:terms]
        # Search mode
        @product_markups = []

        # Don't separate terms to build an AND close, and not a OR
        @product_markups = MnoEnterprise::ProductMarkup.includes(DEPENDENCIES).where(JSON.parse(params[:terms]))
        response.headers['X-Total-Count'] = @product_markups.count
      else
        # Index mode
        query = MnoEnterprise::ProductMarkup.apply_query_params(params).includes(DEPENDENCIES)
        @product_markups = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/product_markups/1
    def show
      @product_markup = MnoEnterprise::ProductMarkup.find_one(params[:id], :product, :organization)
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

  end
end
