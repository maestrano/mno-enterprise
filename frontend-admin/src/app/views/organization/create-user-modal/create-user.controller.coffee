@App.controller 'CreateUserController', ($filter, $stateParams, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, USER_ROLES, organization) ->
  'ngInject'
  vm = this

  vm.USER_ROLES = USER_ROLES

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.addUser(organization, vm.user).then(
      (success) ->
        toastr.success("#{vm.user.name} #{vm.user.surname} has been successfully added.")
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.user)
      (error) ->
        toastr.error("An error occurred while adding #{vm.user.name} #{vm.user.surname}.")
        MnoErrorsHandler.processServerError(error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
