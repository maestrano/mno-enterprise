json.user do
  json.id @user.id
  json.name @user.name
  json.surname @user.surname
  json.email @user.email
  json.underFreeTrial (@user.free_trial_end_at && @user.free_trial_end_at > Time.now)
  json.loggedIn !!@current_user
  json.createdAt @user.created_at
  json.freeTrialEndAt @user.free_trial_end_at
  json.company @user.company
  json.phone @user.phone
  json.phone_country_code @user.phone_country_code
  json.website @user.website
  json.reseller_code @user.reseller_code
  json.email_opt_out @user.email_opt_out?
  json.country_code @user.geo_country_code || 'US'

  # Feature Segregation
  json.hasAnalyticsBetaAccess @user.get_metadata('has_analytics_beta_access')

  if @current_user
    json.organizations do
      json.array! @organizations do |org|
        json.id org.id
        json.name org.name
        json.current_user_role @current_user.role(org)
        json.is_customer_account @current_user.customer_organization?(org)
        json.is_reseller_branch org.reseller_branch?
      end
    end
    json.administratedOrga do
      json.array! @administrated_orgas do |orga|
        json.name orga.name
        json.uid orga.uid
      end
    end
    if @deletion_request
      json.deletionRequest do
        json.token @deletion_request.token
      end
    end
  end
end
