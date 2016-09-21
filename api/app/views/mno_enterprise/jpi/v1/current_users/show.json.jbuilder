json.cache! ['v1', @user.cache_key] do
  json.current_user do
    json.id @user.id
    json.name @user.name
    json.surname @user.surname
    json.email @user.email
    json.logged_in !!@user.id
    json.created_at @user.created_at ? @user.created_at.iso8601 : nil
    json.company @user.company
    json.phone @user.phone
    json.phone_country_code @user.phone_country_code
    json.country_code @user.geo_country_code || 'US'
    json.website @user.website
    json.sso_session @user.sso_session
    json.admin_role @user.admin_role
    json.avatar_url avatar_url(@user)
    if current_impersonator
      json.current_impersonator true
    end

    if @user.respond_to?(:intercom_user_hash)
      json.user_hash @user.intercom_user_hash
    end

    # Embed association if user is persisted
    if @user.id
      json.organizations do
        json.array! (@user.organizations || []) do |o|
          json.id o.id
          json.uid o.uid
          json.name o.name
          json.currency o.billing_currency
          json.current_user_role o.role
          json.has_myob_essentials_only o.has_myob_essentials_only?
          json.financial_year_end_month o.financial_year_end_month
        end
      end

      if @user.deletion_request.present?
        json.deletion_request do
          json.extract! @user.deletion_request, :id, :token
        end
      end
    end
  end
end
