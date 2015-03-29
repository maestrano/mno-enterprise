maestranoServices = angular.module('maestrano.services',[
  'maestrano.services.apps-list-helper',
  'maestrano.services.current-user-svc',
  'maestrano.services.shopping-cart'
  'maestrano.services.current-currency',
  'maestrano.services.miscellaneous',
  'maestrano.services.marketplace-svc',
  'maestrano.services.message-svc',
  'maestrano.services.modal-svc',

  # Dashboard
  'maestrano.services.dashboard.apps-document',
  'maestrano.services.dashboard.organization-svc',
  'maestrano.services.dashboard.team-svc'
  'maestrano.services.dashboard.user',
  'maestrano.services.dashboard.app-instance'
])
