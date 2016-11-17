@App.controller 'ConnectMyobModalCtrl', ($window, $httpParamSerializer, $uibModalInstance, app) ->
  'ngInject'
  vm = this

  vm.app = app
  vm.path = "/mnoe/webhook/oauth/" + vm.app.uid + "/authorize?"
  vm.form = {
    perform: true
    version: "essentials"
  }
  vm.versions = [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]

  vm.connect = (form) ->
    $window.location.href = vm.path + $httpParamSerializer(form)

  vm.close = ->
    $uibModalInstance.close()

  return

