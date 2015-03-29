module = angular.module('maestrano.components.mno-current-currency',['maestrano.assets'])

#============================================
# Component 'Current Currency'
#============================================


module.controller('MnoCurrentCurrencyCtrl',['$scope', 'CurrentCurrency', ($scope, CurrentCurrency) ->

  $scope.currentCurrency = ->
    return CurrentCurrency.val

])

module.directive('mnoCurrentCurrency', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {}
    template: "<span>{{currentCurrency()}}</span>",
    controller: 'MnoCurrentCurrencyCtrl',
  }
])
