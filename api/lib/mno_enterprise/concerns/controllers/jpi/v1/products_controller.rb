module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  def index
    @products = MnoEnterprise::Product.includes(:values, :assets, :categories, :product_pricings, :product_contracts).all
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product.includes(:values, :assets, :categories, :product_pricings, :product_contracts).find(params[:id]).first
  end
end
