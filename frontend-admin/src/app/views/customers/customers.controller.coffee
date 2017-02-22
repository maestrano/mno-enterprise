@App.controller 'CustomersController', ($scope, $uibModal, MnoeUsers, MnoeOrganizations, MnoeObservables, OBS_KEYS) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

  # Display user invitation modal
  vm.inviteUserModal = () ->
    $uibModal.open(
      templateUrl: 'app/views/customers/invite-user-modal/invite-user.html'
      controller: 'InviteUserController'
      controllerAs: 'vm'
    )

  updateUsersCounter = (response) ->
    vm.users.totalCount = response.headers('x-total-count')
    return

  MnoeObservables.registerCb(OBS_KEYS.userChanged, updateUsersCounter)

  MnoeOrganizations.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.organizations.totalCount = response.headers('x-total-count')
      )
  )

  $scope.$on('$destroy', () ->
    MnoeObservables.unsubscribe(OBS_KEYS.userChanged, updateUsersCounter)
  )

  return
