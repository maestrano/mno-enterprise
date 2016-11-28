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

  # POST /mnoe/jpi/v1/marketplace/:id/add_rating
  def add_rating
    @app = MnoEnterprise::App.find(params[:id])
    return render json: "could not find App #{params[:id]}", status: :not_found unless @app
    rating = MnoEnterprise::AppUserRating.new(rating_params(@app.id))
    if rating.save
      head :created
    else
      render json: rating.errors, status: :bad_request
    end
  end

  def rating_params(app_id)
    params.require(:app_user_rating).permit(:rating, :description, :organization_id)
      .merge(app_id: app_id, user_id: current_user.id)
  end

end
