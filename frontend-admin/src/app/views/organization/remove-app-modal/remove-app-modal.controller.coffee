@App.controller 'RemoveAppModalCtrl', ($scope, $uibModalInstance, MnoeAppInstances, app) ->
  'ngInject'
  vm = this
  vm.app = app
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
