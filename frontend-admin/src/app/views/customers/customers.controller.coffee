@App.controller 'CustomersController', ($uibModal, MnoeUsers, MnoeOrganizations) ->
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

  MnoeUsers.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.users.totalCount = response.headers('x-total-count')
      )
  )

  MnoeOrganizations.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.organizations.totalCount = response.headers('x-total-count')
      )
  )

  return
