angular.module('maestrano.services.current-currency', []).factory('CurrentCurrency', ['$http','$window', ($http,$window) ->
  service = {}
  service.val = if $window.currentVisitorCountryCode is "AU" then "AUD" else "USD"

  return service

])
