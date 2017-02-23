@App.controller 'CreateStaffController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, ADMIN_ROLES) ->
  'ngInject'
  vm = this

  vm.admin_roles = ADMIN_ROLES

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.addStaff(vm.user).then(
      (success) ->
        toastr.success("#{vm.user.name} #{vm.user.surname} has been successfully added.")
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.data)
      (error) ->
        toastr.error("An error occurred while adding #{vm.user.name} #{vm.user.surname}.")
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
