@App.controller 'ConnectMyobModalCtrl', ($window, $httpParamSerializer, $uibModalInstance, MnoAppsInstances, app) ->
  'ngInject'
  vm = this

  vm.app = app
  vm.form = {
    perform: true
    version: "essentials"
  }
  vm.versions = [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]

  vm.connect = (form) ->
    $window.location.href = MnoAppsInstances.oAuthConnectPath(app, $httpParamSerializer(form))

  vm.close = ->
    $uibModalInstance.close()

  return

