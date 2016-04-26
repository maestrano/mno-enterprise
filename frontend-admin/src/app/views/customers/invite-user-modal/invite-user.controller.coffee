@App.controller 'InviteUserController', ($filter, $stateParams, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, USER_ROLES) ->
  'ngInject'
  vm = this

  vm.USER_ROLES = USER_ROLES

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.sendSignupEmail(vm.user.email).then(
      (success) ->
        toastr.success("An email to #{vm.user.email} has been successfully sent.")
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(vm.user.email)
      (error) ->
        toastr.error("An error occurred while sending an email to #{vm.user.email}.")
        MnoErrorsHandler.processServerError(error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
