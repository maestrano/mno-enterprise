# This service provides exchange rates from AUD to another currency
# as well as currency information (symbol, subunit symbol etc.)
# ---
# Note that rates are received from Maestrano in percent
# E.g: 100 AUD = 92.31 USD
angular.module('maestrano.exchange-rates', []).factory('ExchangeRates', ['$http', ($http) ->
  service = {}
  service.ratesUrl = '/api/v1/exchange_rates'
  service.rates = {}
  service.defCurrency = if window.currentVisitorCountryCode is "AU" then "AUD" else "USD"
  service.then = () ->

  #==================================
  # Money Object
  #==================================
  # Exchange object
  moneyObject = {}

  # Return a new money object in the
  # requested currency
  moneyObject.to = (currency) ->
    self = this
    if self.currency
      if self.currency == currency
        return self
      else
        money = angular.copy(moneyObject)
        money.currency = currency
        money.amount = (self.amount * service.rates[currency].value) / service.rates[self.currency].value
        # Round the number if no subunit
        if !service.rates[currency].options.subunit_to_unit || service.rates[currency].options.subunit_to_unit == 1
          money.amount = Math.round(money.amount)
        return money

  # Return the money object in the service
  # default currency
  moneyObject.toDefault = () ->
    self = this
    self.to(service.defaultCurrency())

  # Format a money object for display
  moneyObject.format = () ->
    self = this
    accounting.formatMoney(self.amount, service.rates[self.currency].options)

  # Format a money object in fractional only (like 99ct)
  # if the amount is below the subunit_to_unit threshold
  moneyObject.formatFractional = () ->
    self = this
    currency = service.rates[self.currency]
    if !currency.options.subunit_to_unit || currency.options.subunit_to_unit == 1
      return self.format()
    else
      subunit_amount = Math.round(self.amount*currency.options.subunit_to_unit)
      if subunit_amount >= currency.options.subunit_to_unit
        return self.format()
      else
        return accounting.formatMoney(subunit_amount, { symbol: currency.options.subunit_symbol, format: currency.options.subunit_format, precision: 0 })

  moneyObject.amount = ->
    self = this
    return self.amount


  #==================================
  # Service
  #==================================
  # Load the rates from Maestrano
  # and populate the then function
  service.loadRates = () ->
    self = service
    query = $http.get(self.ratesUrl)
    self.then = query.then
    query.success((data) ->
      self.rates = data
    )

  service.newMoneyObject = (amount,currency) ->
    money = angular.copy(moneyObject)
    money.amount = amount
    money.currency = currency
    return money

  # Take a float amount in whole unit (eg: dollar,Yen)
  # Take a currency in iso-3 standard (eg: AUD)
  # ---
  # This method returns an moneyObject
  # You can convert rates like that:
  # ExchangeRates.exchange(100,'AUD').to('USD')
  service.exchange = (amount,currency) ->
    return service.newMoneyObject(amount,currency)

  # Getter/Setter for defaultCurrency
  service.defaultCurrency = (currency = null) ->
    if angular.isString(currency)
      service.defCurrency = currency
    return service.defCurrency

  service.loadRates()

  return service
])
