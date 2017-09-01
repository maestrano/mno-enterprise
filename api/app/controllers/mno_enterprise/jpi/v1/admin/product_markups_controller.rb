module MnoEnterprise
  class Jpi::V1::Admin::ProductMarkupsController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:product, :organization]

    # GET /mnoe/jpi/v1/admin/product_markups
    def index
      if params[:terms]
        # Search mode
        @product_markups = []
        JSON.parse(params[:terms]).map { |t| @product_markups = @product_markups | MnoEnterprise::ProductMarkup.includes(DEPENDENCIES).where(Hash[*t]) }
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
      @product_markup = MnoEnterprise::ProductMarkup.create(product_markups_create_params)
      if @product_markup.errors.empty?
        render :show
      else
        render json: @product_markup.errors, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/product_markups/:id
    def update
      # TODO: replace with authorize/ability
        @product_markup = MnoEnterprise::ProductMarkup.find_one(params[:id])
        @product_markup.update(product_markups_params)
        render :show
    end

    # DELETE /mnoe/jpi/v1/admin/product_markups/1
    def destroy
      product_markups = MnoEnterprise::ProductMarkup.find_one(params[:id])
      product_markups.destroy
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
