# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
dashboardComponents = angular.module('maestrano.dashboard', [
  'maestrano.dashboard.dashboard-apps-list',
  'maestrano.dashboard.dashboard-account',
  'maestrano.dashboard.dashboard-menu',
  'maestrano.dashboard.dashboard-app-deletion-request',

  # Marketplace Section
  'maestrano.dashboard.dashboard-marketplace',
  'maestrano.dashboard.dashboard-marketplace-app',

  # Company Section
  'maestrano.dashboard.dashboard-organization-index',
  'maestrano.dashboard.dashboard-organization-credit-card',
  'maestrano.dashboard.dashboard-organization-invoices',
  'maestrano.dashboard.dashboard-organization-billing',
  'maestrano.dashboard.dashboard-organization-arrears',
  'maestrano.dashboard.dashboard-organization-settings',
  'maestrano.dashboard.dashboard-organization-members',
  'maestrano.dashboard.dashboard-organization-teams',
  'maestrano.dashboard.dashboard-organization-team-list',
  ]
)

