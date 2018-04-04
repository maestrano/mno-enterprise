json.id app_instance.id
json.uid app_instance.uid
json.stack app_instance.stack
json.name app_instance.name
json.status app_instance.status
json.oauth_keys_valid app_instance.oauth_keys_valid
json.created_at app_instance.created_at
json.per_user_licence app_instance.per_user_licence
json.last_sync_at app_instance.sync_status&.finished_at

if app_instance.oauth_company
  json.oauth_company_name app_instance.oauth_company
end
#
# if app_instance.connector_stack? && app_instance.oauth_keys && app_instance.oauth_keys[:version]
#   json.connector_version app_instance.oauth_keys[:version]
# end

app_instance.app.tap do |a|
  json.app_id a.id
  json.app_name a.name
  json.app_nid a.nid
  json.logo a.logo
  json.add_on a.add_on?
  json.data_sharing a.connec_ready?
  json.tiny_description a.tiny_description
  json.getting_started markdown(a.getting_started)
  json.support_url a.support_url
end
