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
    last_modified = app_relation.order_by('updated_at.desc').limit(1).first.updated_at

    if stale?(last_modified: last_modified)
      @apps = app_relation.to_a
      @apps.sort_by! { |app| [app.rank ? 0 : 1 , app.rank] } # the nil ranks will appear at the end
      @categories = MnoEnterprise::App.categories(@apps)
      @categories.delete('Most Popular')
      respond_to do |format|
        format.json
      end
    end
  end

  # GET /mnoe/jpi/v1/marketplace/1
  def show
    @app = MnoEnterprise::App.find(params[:id])
  end

  def app_relation
    MnoEnterprise::App.all
  end
end
