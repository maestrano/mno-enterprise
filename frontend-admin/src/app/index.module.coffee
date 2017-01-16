@App = angular.module 'frontendAdmin', [
  # Default configuration
  'mnoEnterprise.defaultConfiguration',
  # Runtime configuration
  'mnoEnterprise.configuration',

  'ngAnimate',
  'ngAria',
  'ngCookies',
  'ngMessages',
  'restangular',
  'ui.router',
  'ui.bootstrap',
  'toastr',
  'ncy-angular-breadcrumb',
  'platanus.inflector',
  'smart-table',
  'angularMoment',
  'duScroll',
  'ngPageTitle'
]
