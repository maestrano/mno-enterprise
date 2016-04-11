@App.controller 'OrganizationController', ($filter, $stateParams, $uibModal, toastr, MnoeOrganizations, MnoeUsers, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.orgId = $stateParams.orgId
  vm.users = {}
  vm.mnoAppInstances = MnoAppsInstances

  # Display user creation modal
  vm.users.createUserModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/organization/create-user-modal/create-user.html'
      controller: 'CreateUserController'
      controllerAs: 'vm'
      resolve:
        organization: vm.organization
    )
    modalInstance.result.then(
      (user) ->
        # Push user to the current list of users
        vm.organization.members.push(user)
    )

  # Get the organization
  MnoeOrganizations.get($stateParams.orgId).then(
    (response) ->
      vm.organization = response.data
      vm.organization.invoices = $filter('orderBy')(vm.organization.invoices, '-started_at')
  )

  return vm
