# Configuration module
#
angular.module('mnoEnterprise.configuration', [])
  .constant('IMPAC_CONFIG', <%= Settings.impac.to_json.html_safe %>)
  .constant('I18N_CONFIG', {
    enabled: <%= Settings.system.i18n.enabled %>,
    available_locales: <%= @available_locales.to_json.html_safe %>,
    preferred_locale: <%= Settings.system.i18n.preferred_locale.to_json.html_safe %>
  })
  .constant('ADMIN_PANEL_CONFIG', <%= Hash(Settings.admin_panel).to_json.html_safe %>)
  .constant('DASHBOARD_CONFIG', <%= Hash(Settings.dashboard).to_json.html_safe %>)
  .constant('GOOGLE_TAG_CONTAINER_ID', <%= MnoEnterprise.google_tag_container.to_json.html_safe %>)
  .constant('INTERCOM_ID', <%= MnoEnterprise.intercom_app_id.to_json.html_safe %>)
  .constant('APP_NAME', <%= MnoEnterprise.app_name.to_json.html_safe %>)
  .constant('URL_CONFIG', <%= Hash(Settings.url_config).to_json.html_safe %>)
  .constant('DEVISE_CONFIG', {
    registerable: <%= @devise_mapping.registerable? %>,
    recoverable: <%= @devise_mapping.recoverable? && MnoEnterprise.style.devise.forgot_password_link_shown %>,
    confirmable: <%= @devise_mapping.confirmable? && MnoEnterprise.style.devise.confirmation_link_shown %>,
    lockable: <%= @devise_mapping.lockable? && MnoEnterprise.style.devise.unlock_link_shown %>
  })
