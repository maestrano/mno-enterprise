app_instance ||= @app_instance

json.id app_instance.id
json.uid app_instance.uid
json.stack app_instance.stack
json.name app_instance.name
json.status app_instance.simple_status
json.loadingUrl app_loading_url(app_instance.id)
json.oauthKeysValid app_instance.oauth_keys_valid?
json.httpUrl app_instance.http_url
json.microsoftTrialUrl app_instance.microsoft_trial_url
json.createdAt app_instance.created_at

if app_instance.connector_stack? && app_instance.oauth_keys && app_instance.oauth_keys[:company_name]
  json.oauthCompanyName app_instance.oauth_keys[:company_name]
end

if app_instance.connector_stack? && app_instance.oauth_keys && app_instance.oauth_keys[:version]
  json.connectorVersion app_instance.oauth_keys[:version]
end

app_instance.app.tap do |app|
  json.appName app.name
  json.appNid app.nid
  json.logo app.logo.url
  if app.tutorial_page
    json.tutorial wiki_page_path(app.tutorial_page)
  end
end

json.plan do
  json.partial! 'jpi/v1/dashboard/plan/show', app_instance: app_instance, show_timestamp:false
end
