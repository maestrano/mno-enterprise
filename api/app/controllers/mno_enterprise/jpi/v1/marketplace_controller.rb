module MnoEnterprise
  class Jpi::V1::MarketplaceController < ApplicationController
    respond_to :json

    # GET /mnoe/mnoe/jpi/v1/marketplace
    def index
      @apps = if MnoEnterprise.marketplace_listing
        MnoEnterprise::App.where('nid.in' => MnoEnterprise.marketplace_listing).to_a
      else
        MnoEnterprise::App.all.to_a
      end
      @apps.sort_by! { |app| [app.rank ? 1 : (1.0 / 0) , app.rank] }
      @categories = MnoEnterprise::App.categories(@apps)
      @categories.delete('Most Popular')
    end

    # GET /mnoe/jpi/v1/marketplace/1
    def show
      @app = MnoEnterprise::App.find(params[:id])
    end
  end
end
