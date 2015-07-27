# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
analyticsComponents = angular.module('maestrano.user-setup', [
  'maestrano.user-setup.index'
  ]
)

