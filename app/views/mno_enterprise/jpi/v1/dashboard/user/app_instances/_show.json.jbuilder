app_instance ||= @app_instance

if app_instance
  json.id app_instance.id
  json.status app_instance.simple_status
  json.name app_instance.name
  json.app_name app_instance.name
  json.next_status app_instance.next_status
  json.durations app_instance.app.durations
  json.started_at app_instance.started_at
  json.stopped_at app_instance.stopped_at
  json.created_at app_instance.created_at
  json.is_online app_instance.online?
  json.first_credentials app_instance.first_credentials
  json.tutorial_page_url app_instance.tutorial_page && wiki_page_path(app_instance.tutorial_page)
  json.errors app_instance.errors.full_messages
  json.sso_enabled !!app_instance.sso_enabled
  json.http_url app_instance.http_url
end
