module MnoEnterprise::Concerns::Controllers::Jpi::V1::MarketplaceController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    PRODUCT_DEPENDENCIES = [:app, :values, :'values.field', :categories]
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
    product_last_modified = product_relation(parent_organization_id).order(updated_at: :desc).select(:updated_at).first&.updated_at || Time.new(0)
    tenant_last_modified = MnoEnterprise::Tenant.show.updated_at
    @last_modified = [tenant_last_modified, product_last_modified].max

    # Fetch application listings & pricings
    if stale?(last_modified: @last_modified)
      @products = fetch_products
      @categories = MnoEnterprise::Product.categories(@products)

      respond_to do |format|
        format.json
      end
    end
  end

  # GET /mnoe/jpi/v1/marketplace/1(?organization_id=123)
  def show
    @app = app_relation(parent_organization_id).find(params[:id]).first
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

  # Return the organization_id passed as query parameters if the current_user
  # has access to it
  def parent_organization_id
    return nil unless current_user && params[:organization_id].presence
    @org_id ||= MnoEnterprise::Organization
                  .select(:id)
                  .where('id' => params[:organization_id], 'users.id' => current_user.id)
                  .first&.id
  end

  def fetch_products
    Rails.cache.fetch("marketplace/index-products-#{@last_modified}-#{I18n.locale}-#{parent_organization_id}") do
      relation = product_relation(parent_organization_id).select(:id, :logo, :name, :local, :nid,
        :categories, { categories: [:name] }, :app, { apps: [:id] }, :values, { values: [:data, :field] }
      ).includes(PRODUCT_DEPENDENCIES).where(active: true)
      MnoEnterprise::Product.fetch_all(relation)
    end
  end
end
