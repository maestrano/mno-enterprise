module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  DEPENDENCIES = [:'values.field', :assets, :categories, :product_contracts]

  def index
    query = MnoEnterprise::Product.apply_query_params(params).includes(DEPENDENCIES).where(active: true, purchasables: 'user_purchasable')

    # Ensure prices include organization-specific markups/discounts
    if params[:organization_id] && parent_organization
      query = query.with_params(_metadata: { organization_id: parent_organization.id })
    end

    # Paginate if requested, otherwise return all the records, as opposed to the default 25.
    @products = params[:limit] && params[:offset] ? query.to_a : MnoEnterprise::Product.fetch_all(query)
    response.headers['X-Total-Count'] = query.meta.record_count
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product
      .includes(DEPENDENCIES)
      .find(params[:id])
      .first
  end

  # GET /mnoe/jpi/v1/products/id/custom_schema
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
end
