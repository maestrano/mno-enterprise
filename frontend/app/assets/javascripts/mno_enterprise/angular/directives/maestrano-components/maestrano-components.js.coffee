# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
maestranoComponents = angular.module('maestrano.components', [
  'maestrano.components.mno-flash-msg',
  'maestrano.components.mno-notification-widget',
  'maestrano.components.mno-loading-lounge',
  'maestrano.components.mno-password-strength',
  'maestrano.components.mno-compile',
  'maestrano.components.mno-password',
  ]
)
