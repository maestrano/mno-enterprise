@App.controller 'ConnectXeroModalCtrl', ($window, $httpParamSerializer, $uibModalInstance, app) ->
  'ngInject'
  vm = this

  vm.app = app
  vm.path = "/mnoe/webhook/oauth/" + vm.app.uid + "/authorize?"
  vm.form = {
    perform: true
    "xero_country": "AU"
  }
  vm.countries = [
    {name: "Australia", value: "AU"},
    {name: "USA", value: "US"}
  ]

  vm.connect = (form) ->
    form['extra_params[]'] = "payroll" if vm.payroll
    $window.location.href = vm.path + $httpParamSerializer(form)

  vm.close = ->
    $uibModalInstance.close()

  return

