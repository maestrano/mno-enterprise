module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products
  def index
    @products = MnoEnterprise::Product.includes(:values, :assets, {product_categories: :categories}).all
  end

  # GET /mnoe/jpi/v1/products/id
  def show
    @product = MnoEnterprise::Product.includes(:values, :assets, {product_categories: :categories}).find(params[:id])
  end
end
