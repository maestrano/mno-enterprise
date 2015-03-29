module = angular.module('maestrano.components.mno-currency-widget',['maestrano.assets'])

#============================================
# Component 'Currency Widget'
#============================================


module.controller('MnoCurrencyWidgetCtrl',['$scope', 'CurrentCurrency', ($scope, CurrentCurrency) ->


  $scope.currencies = ["USD","AUD","CAD","CNY","EUR","GBP","HKD","INR","JPY","NZD","SGD","PHP"]
  $scope.currentCurrency = CurrentCurrency.val
  
  # Set the currency
  $scope.setCurrency = (currency) ->
    CurrentCurrency.val = currency
  
  # Outject 'selectedCurrency' function in scope.
  # 'selected-currency' is accessible via directive attribute
  # and can be called by other element on the page that are
  # not angular ready (haml pages)
  $scope.selectedCurrency = ->
    return CurrentCurrency.val
    
  # Initialize current currency based on user location
  curr = if window.currentVisitorCountryCode is "AU" then "AUD" else "USD"
  $scope.setCurrency(curr)

])

module.directive('mnoCurrencyWidget', ['TemplatePath', '$timeout', (TemplatePath, $timeout) ->
  return {
      link: (scope,element,attrs) ->
        $timeout ->
          $('select.select-picker').selectpicker()
        ,1000
      restrict: 'A',
      scope:
        selectedCurrency: '=?'
      templateUrl: TemplatePath['maestrano-components/currency_widget.html'],
      controller: 'MnoCurrencyWidgetCtrl',
  }
])
