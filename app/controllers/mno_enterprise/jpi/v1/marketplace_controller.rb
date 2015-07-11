module MnoEnterprise
  class Jpi::V1::MarketplaceController < ApplicationController
    respond_to :json

    # GET /mnoe/mnoe/jpi/v1/marketplace
    def index
      @apps = MnoEnterprise::App.where('nid.in' => MnoEnterprise.marketplace_listing).to_a
      @categories = MnoEnterprise::App.categories(@apps)
      @categories.delete('Most Popular')
    end

    # GET /mnoe/jpi/v1/marketplace/1
    def show
      @app = MnoEnterprise::App.find(params[:id])
    end
  end
end
