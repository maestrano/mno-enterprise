# Configuration module
#
# Recompile if the settings change

# TODO: regroup under DASHBOARD_CONFIG?
angular.module('mnoEnterprise.configuration', [])
  .constant('IMPAC_CONFIG', <%= Settings.impac.to_json.html_safe %>)
  .constant('I18N_CONFIG', {
    enabled: <%= MnoEnterprise.i18n_enabled %>,
    available_locales: <%= I18n.available_locales.to_json.html_safe %>
  })
  .constant('PRICING_CONFIG', <%= Hash(Settings.pricing).to_json.html_safe %>)
  .constant('DOCK_CONFIG', <%= Hash(Settings.dock).to_json.html_safe %>)
  .constant('DEVELOPER_SECTION_CONFIG', <%= Hash(Settings.developer).to_json.html_safe %>)
  .constant('ONBOARDING_WIZARD_CONFIG', <%= Hash(Settings.onboarding_wizard).to_json.html_safe %>)
  .constant('REVIEWS_CONFIG', <%= Hash(Settings.reviews).to_json.html_safe %>)
  .constant('MARKETPLACE_CONFIG', <%= Hash(Settings.marketplace).to_json.html_safe %>)
  .constant('ADMIN_PANEL_CONFIG', <%= Hash(Settings.admin_panel).to_json.html_safe %>)
  .constant('PAYMENT_CONFIG', <%= Hash(Settings.payment).to_json.html_safe %>)
  .constant('ORGANIZATION_MANAGEMENT', <%= Hash(Settings.organization_management).to_json.html_safe %>)
  .constant('USER_MANAGEMENT', <%= Hash(Settings.user_management).to_json.html_safe %>)
  .constant('AUDIT_LOG', <%= Hash(Settings.audit_log).to_json.html_safe %>)
  .constant('GOOGLE_TAG_CONTAINER_ID', <%= MnoEnterprise.google_tag_container.to_json.html_safe %>)
  .constant('INTERCOM_ID', <%= MnoEnterprise.intercom_app_id.to_json.html_safe %>)
  .constant('APP_NAME', <%= MnoEnterprise.app_name.to_json.html_safe %>)
  .constant('URL_CONFIG', <%= Hash(Settings.url_config).to_json.html_safe %>)
  .constant('CONFIG_JSON_SCHEMA', <%= Hash(MnoEnterprise::TenantConfig::CONFIG_JSON_SCHEMA).to_json.html_safe %>)
