# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
maestranoComponents = angular.module('maestrano.components', [
  'maestrano.components.mno-match',
  'maestrano.components.mno-flash-msg',
  'maestrano.components.mno-helptext',
  'maestrano.components.mno-autostop-app',
  'maestrano.components.mno-notification-widget',
  'maestrano.components.mno-loading-lounge',
  'maestrano.components.mno-scroll-to',
  'maestrano.components.mno-currency-widget',
  'maestrano.components.file-model',
  'maestrano.components.mno-sync-config',
  'maestrano.components.mno-shopping-cart'
  'maestrano.components.mno-price-converter',
  'maestrano.components.mno-current-currency',
  'maestrano.components.mno-password-strength',
  'maestrano.components.mno-editable',
  'maestrano.components.mno-typeahead',
  'maestrano.components.mno-message-modal'
  'maestrano.components.mno-compile'
  ]
)
