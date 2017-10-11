module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  DEPENDENCIES = [:'values.field', :assets, :categories, :product_pricings, :product_contracts]

  def index
    query = MnoEnterprise::Product.apply_query_params(params).includes(DEPENDENCIES).where(active: true)

    # Ensure prices include organization-specific markups/discounts
    if params[:organization_id] && parent_organization
      query = query.with_params(_metadata: { organization_id: parent_organization.id })
    end

    @products = MnoEnterprise::Product.fetch_all(query)
    response.headers['X-Total-Count'] = query.meta.record_count
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product.find_one(params[:id], DEPENDENCIES)
  end
end
