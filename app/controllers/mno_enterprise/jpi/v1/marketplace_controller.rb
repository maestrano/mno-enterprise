module MnoEnterprise
  class Jpi::V1::MarketplaceController < ApplicationController
    respond_to :json
  
    # GET /mnoe/jpi/v1/marketplace
    def index
      @categories = MnoEnterprise::App.categories
      @categories.delete('Most Popular')
      @apps = MnoEnterprise::App.active
    end
  
    # GET /jpi/v1/marketplace/1
    def show
      @app = MnoEnterprise::App.find(params[:id])
    end
  end
end