module MnoEnterprise::Concerns::Controllers::Jpi::V1::MarketplaceController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    PRODUCT_DEPENDENCIES = [:'values.field', :assets, :categories, :product_pricings, :product_contracts]
    respond_to :json
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /mnoe/jpi/v1/marketplace(?organization_id=123)
  # If an organization_id is passed then all pricing details will take
  # into any markup/discounts applied specifically to this organization
  def index
    expires_in 0, public: true, must_revalidate: true

    # Compute cache key timestamp
    app_last_modified = app_relation(parent_organization_id).order(updated_at: :desc).select(:updated_at).first&.updated_at || Time.new(0)
    product_last_modified = product_relation(parent_organization_id).order(updated_at: :desc).select(:updated_at).first&.updated_at || Time.new(0)
    tenant_last_modified = MnoEnterprise::Tenant.show.updated_at
    @last_modified = [app_last_modified, tenant_last_modified, product_last_modified].max
    @org_id = parent_organization_id

    # Fetch application listings & pricings
    if stale?(etag: parent_organization, last_modified: @last_modified)

      @apps = fetch_apps
      @products = fetch_products

      @categories = MnoEnterprise::App.categories(@apps)
      @categories.delete('Most Popular')

      respond_to do |format|
        format.json
      end
    end
  end

  # GET /mnoe/jpi/v1/marketplace/1(?organization_id=123)
  def show
    @app = app_relation(parent_organization_id).find_one(params[:id])
  end

  #==================================================================
  # Private
  #==================================================================
  private
  # Return the default relation to use for index and show queries
  def app_relation(org_id = nil)
    rel = MnoEnterprise::App
    rel = rel.with_params(_metadata: { organization_id: org_id }) if org_id.present?
    rel
  end

  def product_relation(org_id = nil)
    rel = MnoEnterprise::Product
    # Ensure prices include organization-specific markups/discounts
    rel = rel.with_params(_metadata: { organization_id: org_id }) if org_id.present?
    rel
  end

  def parent_organization
    return nil unless current_user && params[:organization_id].presence
    @org ||= MnoEnterprise::Organization
                  .select(:id)
                  .where('id' => params[:organization_id], 'users.id' => current_user.id)
                  .first
  end

  # Return the organization_id passed as query parameters if the current_user
  # has access to it
  def parent_organization_id
    parent_organization&.id
  end

  def fetch_apps
    Rails.cache.fetch("marketplace/index-apps-#{@last_modified}-#{I18n.locale}-#{parent_organization_id}") do
      apps = MnoEnterprise::App.fetch_all(app_relation(parent_organization_id).includes(:app_shared_entities, { app_shared_entities: :shared_entity }).where(active: true))
      apps.sort_by! { |app| [app.rank ? 0 : 1, app.rank] } # the nil ranks will appear at the end
      apps
    end
  end

  def fetch_products
    Rails.cache.fetch("marketplace/index-products-#{@last_modified}-#{I18n.locale}-#{parent_organization_id}") do
      MnoEnterprise::Product.fetch_all(product_relation(parent_organization_id).includes(PRODUCT_DEPENDENCIES).where(active: true))
    end
  end
end
