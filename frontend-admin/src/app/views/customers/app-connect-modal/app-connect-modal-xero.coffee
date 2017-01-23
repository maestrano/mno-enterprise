@App.controller 'ConnectXeroModalCtrl', ($window, $httpParamSerializer, $uibModalInstance, MnoAppsInstances, app) ->
  'ngInject'
  vm = this

  vm.app = app
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
    $window.location.href = MnoAppsInstances.oAuthConnectPath(app, $httpParamSerializer(form))

  vm.close = ->
    $uibModalInstance.close()

  return

