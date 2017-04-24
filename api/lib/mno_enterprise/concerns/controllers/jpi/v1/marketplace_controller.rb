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
    expires_in 0, public: true, must_revalidate: true
    last_modified = app_relation.order(updated_at: :desc).select(:updated_at).first.updated_at
    if stale?(last_modified: last_modified)
      @apps = app_relation.to_a
      @apps.sort_by! { |app| [app.rank ? 0 : 1, app.rank] } # the nil ranks will appear at the end
      @categories = MnoEnterprise::App.categories(@apps)
      @categories.delete('Most Popular')
      respond_to do |format|
        format.json
      end
    end
  end

  # GET /mnoe/jpi/v1/marketplace/1
  def show
    @app = MnoEnterprise::App.find_one(params[:id])
  end

  def app_relation
    if MnoEnterprise.marketplace_listing
      MnoEnterprise::App.where(nid: MnoEnterprise.marketplace_listing)
    else
      MnoEnterprise::App.where
    end
  end
end
