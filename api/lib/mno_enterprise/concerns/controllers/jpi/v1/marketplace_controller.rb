module MnoEnterprise::Concerns::Controllers::Jpi::V1::MarketplaceController
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
  # GET /mnoe/mnoe/jpi/v1/marketplace
  def index
    @apps = if MnoEnterprise.marketplace_listing
              MnoEnterprise::App.where('nid.in' => MnoEnterprise.marketplace_listing).to_a
            else
              MnoEnterprise::App.all.to_a
            end
    @apps.sort_by! { |app| [app.rank ? 0 : 1 , app.rank] } # the nil ranks will appear at the end
    @categories = MnoEnterprise::App.categories(@apps)
    @categories.delete('Most Popular')
  end

  # GET /mnoe/jpi/v1/marketplace/1
  def show
    @app = MnoEnterprise::App.find(params[:id])
  end
end
