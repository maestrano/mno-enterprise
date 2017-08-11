module MnoEnterprise
  class Jpi::V1::Admin::ProductsController < Jpi::V1::Admin::BaseResourceController

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/admin/products
    DEPENDENCIES = [:values, :assets, :categories, :product_pricings, :product_contracts]

    ATTRIBUTES = [:name, :active, :logo, :external_id]
    PRICING_ATTRIBUTES = [:name, :description, :position, :free, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, :prices, :external_id]

    def index
      if params[:terms]
        # Search mode
        @products = []
        JSON.parse(params[:terms]).map { |t| @products = @products | MnoEnterprise::Product.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @products.count
      else
        # Index mode
        query = MnoEnterprise::Product.apply_query_params(params).where(local: true)
        @products = query.to_a
        response.headers['X-Total-Count'] = query.meta.record_count
      end
    end

    # GET /mnoe/jpi/v1/admin/products/id
    def show
      @product = MnoEnterprise::Product.find_one(params[:id], DEPENDENCIES)
    end

    # POST /mnoe/jpi/v1/admin/products
    def create
      @product = MnoEnterprise::Product.create(product_create_params)
      @product.save
      unless @product.errors.empty?
        render json: @product.errors, status: :bad_request
      end
      if pricings = product_params[:product_pricings]
        pricings.each do |p|
          attributes = p.permit(*PRICING_ATTRIBUTES).merge(product_id: @product.id)
          pricing = MnoEnterprise::ProductPricing.create(attributes)
          unless pricing.errors.empty?
            render json: pricing.errors, status: :bad_request
          end
        end
      end

      @product = @product.load_required(DEPENDENCIES)
      return render :show
    end

    # PATCH /mnoe/jpi/v1/admin/products/:id
    def update
      @product = MnoEnterprise::Product.find_one(params[:id])
      @product.update(product_update_params)
      if @product.errors.any?
        render json: @product.errors, status: :bad_request
      end

      if pricings = product_params[:product_pricings]
        @product = @product.load_required(:product_pricings)
        id_to_pricing = @product.product_pricings.map { |p| [p.id, p] }.to_h
        pricings.each do |p|
          attributes = p.permit(*PRICING_ATTRIBUTES)
          if p[:id]
            pricing = id_to_pricing.delete(p[:id])
          end
          if pricing
            pricing.update(attributes)
          else
            pricing = MnoEnterprise::ProductPricing.create(attributes.merge(product_id: @product.id))
          end
          if pricing.errors.any?
            render json: pricing.errors, status: :bad_request
          end
        end
        id_to_pricing.each_value { |p| p.destroy }
      end

      @product = @product.load_required(DEPENDENCIES)
      return render :show

    end

    # DELETE /mnoe/jpi/v1/admin/products/1
    def destroy
      product = MnoEnterprise::Product.find_one(params[:id])
      product.destroy
      head :no_content
    end

    private

    def product_params
      params.require(:product)
    end

    def product_update_params
      product_params.permit(*ATTRIBUTES)
    end

    def product_create_params
      product_update_params.merge(
        product_type: :product,
        externally_provisioned: false,
      )
    end
  end
end
