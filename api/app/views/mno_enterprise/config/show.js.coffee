# Configuration module
#
angular.module('mnoEnterprise.configuration', [])
  .constant('IMPAC_CONFIG', <%= Settings.impac.to_json.html_safe %>)
  .constant('I18N_CONFIG', {
    enabled: <%= MnoEnterprise.i18n_enabled %>,
    available_locales: <%= I18n.available_locales.to_json.html_safe %>
  })
  .constant('ADMIN_PANEL_CONFIG', <%= Hash(Settings.admin_panel).to_json.html_safe %>)
  .constant('DASHBOARD_CONFIG', <%= Hash(Settings.dashboard).to_json.html_safe %>)
  .constant('GOOGLE_TAG_CONTAINER_ID', <%= MnoEnterprise.google_tag_container.to_json.html_safe %>)
  .constant('INTERCOM_ID', <%= MnoEnterprise.intercom_app_id.to_json.html_safe %>)
  .constant('APP_NAME', <%= MnoEnterprise.app_name.to_json.html_safe %>)
  .constant('URL_CONFIG', <%= Hash(Settings.url_config).to_json.html_safe %>)
  .constant('CONFIG_JSON_SCHEMA', <%= Hash(MnoEnterprise::TenantConfig::CONFIG_JSON_SCHEMA).to_json.html_safe %>)
