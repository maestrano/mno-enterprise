json.id app_instance.id
json.uid app_instance.uid
json.stack app_instance.stack
json.name app_instance.name
json.status app_instance.status
json.oauth_keys_valid app_instance.oauth_keys_valid
json.created_at app_instance.created_at
json.per_user_licence app_instance.per_user_licence
json.channel_id app_instance.channel_id

if app_instance.oauth_company
  json.oauth_company_name app_instance.oauth_company
end

if app_instance.addon_organization
  json.addon_organization app_instance.addon_organization
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
end
