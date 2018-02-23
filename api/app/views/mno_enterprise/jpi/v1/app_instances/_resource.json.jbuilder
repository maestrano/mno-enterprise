json.id app_instance.id
json.uid app_instance.uid
json.stack app_instance.stack
json.name app_instance.name
json.status app_instance.status
json.oauth_keys_valid app_instance.oauth_keys_valid
#json.http_url app_instance.http_url
#json.microsoft_trial_url app_instance.microsoft_trial_url
json.created_at app_instance.created_at

json.per_user_licence app_instance.per_user_licence
json.licences_count app_instance.active_licences_count if app_instance.per_user_licence?

if app_instance.under_free_trial?
  json.free_trial_end_at app_instance.free_trial_end_at
end

if app_instance.oauth_company
  json.oauth_company_name app_instance.oauth_company
end
#
# if app_instance.connector_stack? && app_instance.oauth_keys && app_instance.oauth_keys[:version]
#   json.connector_version app_instance.oauth_keys[:version]
# end

@apps[app_instance.app_id].first.tap do |a|
  json.app_id a.id
  json.app_name a.name
  json.app_nid a.nid
  json.logo a.logo
  json.add_on a.add_on?
end
