# Somehow the whole config/ folder is loaded twice
# To investigate
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
        "dashboard_dashboard_delete" => "Dashboard '%{name}' deleted",
        "widget_create" => "Widget '%{name}' added",
        "user_invite" => "%{user_email} invited"
      }
    }
  end
end
