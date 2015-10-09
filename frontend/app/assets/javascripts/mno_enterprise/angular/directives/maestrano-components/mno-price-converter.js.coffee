module = angular.module('maestrano.components.mno-price-converter',['maestrano.assets'])

#============================================
# Component 'Price Converter'
#============================================


module.controller('MnoPriceConverterCtrl',['$scope', 'ExchangeRates', 'CurrentCurrency', ($scope, ExchangeRates, CurrentCurrency) ->

  ExchangeRates.then ->

    $scope.currencies = ["AUD","CAD","CNY","EUR","GBP","HKD","INR","JPY","NZD","SGD","USD",]
    $scope.currentCurrency = ExchangeRates.defaultCurrency()
    
    # Set currency and outject currency in scope
    $scope.setCurrency = (currency) ->
      ExchangeRates.defaultCurrency(currency)
      $scope.currency = currency

    $scope.convertedPrice = ->
      if $scope.noConversion
        return ExchangeRates.newMoneyObject($scope.price,$scope.currency)
      else
        return ExchangeRates.exchange($scope.price, ($scope.currency || 'AUD')).to(CurrentCurrency.val)

    $scope.style = ->
      if $scope.currencyResponsive
        switch CurrentCurrency.val
          when 'CNY' then 'font-size:28px;'
          when 'HKD' then 'font-size:29px;'
          when 'INR' then 'font-size:25px;'
          when 'JPY' then 'font-size:26px;'
          when 'PHP' then 'font-size:28px;'
          else 'font-size:38px;'

])

module.directive('mnoPriceConverter', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope:
      price:'='
      currencyResponsive:'@'
      currency: '@'
      noConversion: '@'
    template: "<span style='{{style()}}'>{{convertedPrice().format()}}</span>",
    controller: 'MnoPriceConverterCtrl',
  }
])
