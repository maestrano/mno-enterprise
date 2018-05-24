unless defined? AUDIT_LOG_CONFIG
  begin
    AUDIT_LOG_CONFIG = Rails.application.config_for('audit_log')
  rescue
    AUDIT_LOG_CONFIG = {
      "events" => {
        "app_add" => "%{name} added",
        "app_destroy" => "%{name} removed",
        "app_launch" => "%{name} launched",
        "dashboard_create" => "Dashboard '%{name}' created",
        "dashboard_delete" => "Dashboard '%{name}' deleted",
        "widget_create" => "Widget '%{name}' added",
        "widget_delete" => "Widget '%{name}' deleted",
        "widget_update" => "Widget '%{name}' updated with params: '%{widget_action}'",
        "user_invite" => "%{user_email} invited",
        "user_invite_accept" => "%{user_email} accepted invitation",
        "user_confirm" => "%{user_email} accepted invitation",
        "user_add" => "User '%{user_email}' signed up",
        "user_role_update" => "User '%{email}' role changed to '%{role}'",
        "user_role_delete" => "User '%{email}' removed from org",
        "team_add" => "Team '%{name}' created",
        "team_delete" => "Team '%{name}' deleted",
        "team_update" => "Team '%{name}' user list modified. Action: %{action}, User(s) '%{users}'",
        "team_apps_update" => "Team '%{name}' app list modified. New list: '%{apps}'",
        "app_connected" => "App '%{name}' connected",
        "app_disconnected" => "App '%{name}' disconnected",
        "impersonate_created" => "Impersonated session created for user %{user_email}",
        "impersonate_destroyed" => "Impersonated session destroyed",
        "subscription_update" => "%{edit_action}"
      }
    }
  end
end
