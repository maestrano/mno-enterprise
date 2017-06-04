unless defined? AUDIT_LOG_CONFIG
  AUDIT_LOG_CONFIG = Rails.application.config_for('audit_log') rescue {}
end
