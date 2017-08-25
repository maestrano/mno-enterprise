module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  def index
    criteria = MnoEnterprise::Product.includes(:values, :assets, :categories, :product_pricings, :product_contracts)
    @products = MnoEnterprise::Product.fetch_all(criteria)
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product.includes(:values, :assets, :categories, :product_pricings, :product_contracts).find(params[:id]).first
  end
end
