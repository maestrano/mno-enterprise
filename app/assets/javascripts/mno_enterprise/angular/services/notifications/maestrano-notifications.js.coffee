# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
maestranoNotifications = angular.module('maestrano.notifications',
  ['maestrano.notifications.apps',
  ])





