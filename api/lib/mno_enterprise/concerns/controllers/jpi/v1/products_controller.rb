module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  DEPENDENCIES = [:values, :assets, :categories, :product_pricings, :product_contracts]

  def index
    criteria = MnoEnterprise::Product.includes(*DEPENDENCIES)
    @products = MnoEnterprise::Product.fetch_all(criteria)
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product.find_one(params[:id], DEPENDENCIES)
  end
end
