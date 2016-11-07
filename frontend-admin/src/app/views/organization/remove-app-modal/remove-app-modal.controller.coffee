@App.controller 'RemoveAppModalCtrl', ($scope, $uibModalInstance, MnoeAppInstances, app) ->
  'ngInject'
  vm = this
  vm.app = app
  vm.sentence = "Please proceed to the deletion of my app and all data it contains"
  vm.modal = {
    loading: false
  }

  vm.deleteApp = ->
    vm.modal.loading = true
    MnoeAppInstances.terminate(vm.app.id).then(
      (success) ->
        vm.errors = null
        $uibModalInstance.close(true)
    ).finally(-> vm.modal.loading = false)


  vm.closeModal = ->
    $uibModalInstance.close(false)

  return
