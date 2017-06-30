module MnoEnterprise::Concerns::Controllers::Jpi::V1::ProductPricingsController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/products/abc/pricings
  def index
    @pricings = MnoEnterprise::Product.find(params[:id]).pricings
  end
end
