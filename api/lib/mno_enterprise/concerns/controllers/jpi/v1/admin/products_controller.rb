module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::ProductsController
  extend ActiveSupport::Concern

  ATTRIBUTES = [:name, :active, :logo, :external_id]
  DEPENDENCIES = [:'values.field', :assets, :categories, :product_pricings, :product_contracts]
  PRICING_ATTRIBUTES = [:name, :description, :position, :free, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, {:prices => [:currency, :price_cents] }, :external_id]

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/products
  def index
    query = MnoEnterprise::Product.apply_query_params(params).includes(DEPENDENCIES)
    @products = query.to_a
    response.headers['X-Total-Count'] = query.meta.record_count
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
    if pricing_params
      pricing_params.each do |p|
        attributes = p.permit(*PRICING_ATTRIBUTES).merge(product_id: @product.id)
        pricing = MnoEnterprise::ProductPricing.create(attributes)
        unless pricing.errors.empty?
          render json: pricing.errors, status: :bad_request
        end
      end
    end

    @product = @product.load_required(DEPENDENCIES)
    render :show
  end

  # PATCH /mnoe/jpi/v1/admin/products/:id
  def update
    @product = MnoEnterprise::Product.find_one(params[:id])
    @product.update(product_update_params)
    return render json: @product.errors, status: :bad_request if @product.errors.any?
    if pricing_params
      @product = @product.load_required(:product_pricings)
      id_to_pricing = @product.product_pricings.map { |p| [p.id, p] }.to_h
      pricing_params.each do |p|
        attributes = p.permit(*PRICING_ATTRIBUTES)
        pricing = id_to_pricing.delete(p[:id])
        if pricing
          pricing.update(attributes)
        else
          pricing = MnoEnterprise::ProductPricing.create(attributes.merge(product_id: @product.id))
        end
        return render json: pricing.errors, status: :bad_request if pricing.errors.any?
      end
      id_to_pricing.each_value { |p| p.destroy }
    end

    @product = @product.load_required(DEPENDENCIES)
    render :show
  end

  # DELETE /mnoe/jpi/v1/admin/products/1
  def destroy
    product = MnoEnterprise::Product.find_one(params[:id])
    product.destroy
    head :no_content
  end

  # POST /mnoe/jpi/v1/admin/products/1/upload_logo
  def upload_logo
    product = MnoEnterprise::Product.find_one(params[:id])
    image = params[:image]
    # get the logo's temporal path
    image_temp_path = image.tempfile.path
    # open the logo
    image_bin = IO.binread(image_temp_path)
    # encode the logo in base 64
    image_encoded = Base64.encode64(image_bin)

    logo = { data_base64: image_encoded, filename: image.original_filename, content_type: image.content_type }.to_json
    product.update(logo: logo)
    head :created
  end

  private

  def pricing_params
    # Rails consider empty array to be nil
    # https://stackoverflow.com/questions/20164354/rails-strong-parameters-with-empty-arrays
    product_params[:product_pricings] ||= [] if product_params.has_key?(:product_pricings)
    product_params[:product_pricings]
  end

  def product_params
    params.require(:product)
  end

  def product_update_params
    product_params.permit(*ATTRIBUTES).tap do |whitelisted|
      whitelisted[:values_attributes] = product_params[:values_attributes]
    end
  end

  def product_create_params
    product_update_params.merge(
      product_type: :product,
      externally_provisioned: false
    )
  end
end
