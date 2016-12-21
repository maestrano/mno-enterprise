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

  # GET /mnoe/jpi/v1/marketplace/:id/app_comments
  def app_reviews
    @app_reviews = MnoEnterprise::App.find(params[:id]).reviews
    return render json: "could not find Reviews for app #{params[:id]}", status: :not_found unless @app_reviews
    render 'app_reviews'
  end

  # POST /mnoe/jpi/v1/marketplace/:id/app_review
  def app_review
    @app = MnoEnterprise::App.find(params[:id])
    return render json: "could not find App #{params[:id]}", status: :not_found unless @app
    @app_review = MnoEnterprise::AppReview.new(review_params(@app.id))
    if @app_review.save
      @app_review.reload
      render 'app_review'
    else
      render json: @app_review.errors, status: :bad_request
    end
  end

  def review_params(app_id)
    params.require(:app_review).permit(:rating, :description, :organization_id)
      .merge(app_id: app_id, user_id: current_user.id)
  end

end
