module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::ProductsController
  extend ActiveSupport::Concern

  ATTRIBUTES = [:name, :active, :logo, :external_id, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :single_billing_enabled, :billed_locally]
  DEPENDENCIES = [:'values.field', :assets, :categories, :product_pricings, :product_contracts]
  PRICING_ATTRIBUTES = [:name, :description, :position, :free, :pricing_type, :free_trial_enabled, :free_trial_duration, :free_trial_unit, :per_duration, :per_unit, {:prices => [:currency, :price_cents] }, :external_id]

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/admin/products
  def index
    if params[:terms]
      # Search mode
      query = MnoEnterprise::Product.apply_query_params(params)
      @products = MnoEnterprise::Product.fetch_all(query)
      JSON.parse(params[:terms]).map { |t| @products = @products | MnoEnterprise::ProductMarkup.includes(DEPENDENCIES).where(Hash[*t]) }
      response.headers['X-Total-Count'] = @products.count
    else
      query = MnoEnterprise::Product.apply_query_params(params)
      query = query.includes(params[:includes]) if params[:includes]
      query = query.includes(DEPENDENCIES) unless params[:skip_dependencies]

      # Paginate if requested, otherwise return all the records, as opposed to the default 25.
      @products = params[:limit] && params[:offset] ? query.to_a : MnoEnterprise::Product.fetch_all(query)
      response.headers['X-Total-Count'] = query.meta.record_count
    end
  end

  # GET /mnoe/jpi/v1/admin/products/id
  def show
    @product = MnoEnterprise::Product
      .includes(DEPENDENCIES)
      .find(params[:id])
      .first
  end

  # GET /mnoe/jpi/v1/admin/products/id/custom_schema
  # This endpoint is used just to fetch the product's custom_schema. This streamlines
  # error handling, as we don't want the entire product to error out, when its
  # custom_schema is unavailable.
  def custom_schema
    @product = MnoEnterprise::Product
      .with_params(_fetch_custom_schema: true, _edit_action: params[:editAction])
      .select(:custom_schema)
      .find(params[:id])
      .first

    render json: {custom_schema: @product.custom_schema}
  end

  # POST /mnoe/jpi/v1/admin/products
  def create
    @product = MnoEnterprise::Product.create(product_create_params)
    @product.save!
    if pricing_params
      pricing_params.each do |p|
        attributes = p.permit(*PRICING_ATTRIBUTES).merge(product_id: @product.id)
        MnoEnterprise::ProductPricing.create!(attributes)
      end
    end

    @product = @product.load_required(DEPENDENCIES)
    render :show
  end

  # PATCH /mnoe/jpi/v1/admin/products/:id
  def update
    @product = MnoEnterprise::Product.find_one(params[:id])
    @product.update!(product_update_params)
    if pricing_params
      @product = @product.load_required(:product_pricings)
      id_to_pricing = @product.product_pricings.map { |p| [p.id, p] }.to_h
      pricing_params.each do |p|
        attributes = p.permit(*PRICING_ATTRIBUTES)
        pricing = id_to_pricing.delete(p[:id])
        if pricing
          pricing.update!(attributes)
        else
          MnoEnterprise::ProductPricing.create!(attributes.merge(product_id: @product.id))
        end
      end
      id_to_pricing.each_value { |p| p.destroy }
    end

    @product = @product.load_required(DEPENDENCIES)
    render :show
  end

  # DELETE /mnoe/jpi/v1/admin/products/1
  def destroy
    product = MnoEnterprise::Product.find_one(params[:id])
    product.destroy!
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
    product.update!(logo: logo)
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
