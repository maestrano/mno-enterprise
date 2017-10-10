json.cache! ['v2', @user.cache_key] do
  json.current_user do
    json.id @user.id
    json.name @user.name
    json.surname @user.surname
    json.email @user.email
    json.logged_in !!@user.id
    json.created_at @user.created_at ? @user.created_at.iso8601 : nil
    json.company @user.company
    json.phone @user.phone
    json.api_secret @user.api_secret
    json.api_key @user.api_key
    json.phone_country_code @user.phone_country_code
    json.country_code @user.geo_country_code || 'US'
    json.website @user.website
    json.sso_session @user.sso_session
    json.admin_role @user.admin_role
    json.avatar_url avatar_url(@user)
    json.settings @user.settings
    json.sub_tenant_id @user.sub_tenant&.id

    if current_impersonator
      json.current_impersonator true
      json.current_impersonator_role current_impersonator.admin_role
    end

    if @user.respond_to?(:intercom_user_hash)
      json.user_hash @user.intercom_user_hash
    end

    # Embed association if user is persisted
    if @user.id
      json.organizations do
        json.array! @organizations do |o|
          json.id o.id
          json.uid o.uid
          json.name o.name
          json.active o.active?
          json.currency o.billing_currency
          json.current_user_role @user.role(o)
          json.has_myob_essentials_only o.has_myob_essentials_only
          json.financial_year_end_month o.financial_year_end_month
        end
      end

      if @user.current_deletion_request.present?
        json.deletion_request do
          json.extract! @user.current_deletion_request, :id, :token
        end
      end

      json.kpi_enabled !!@user.kpi_enabled
    end
  end
end
