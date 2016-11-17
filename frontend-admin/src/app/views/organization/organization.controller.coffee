@App.controller 'OrganizationController', ($filter, $stateParams, $uibModal, toastr, MnoeOrganizations, MnoeUsers, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.orgId = $stateParams.orgId
  vm.users = {}
  vm.hasDisconnectedApps = false
  vm.status = {}

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
      vm.organization = response.data.plain()
      vm.organization.invoices = $filter('orderBy')(vm.organization.invoices, '-started_at')
      vm.updateStatus()
  )

  vm.updateStatus = ->
    vm.status = {}
    _.map(vm.organization.active_apps,
      (app) ->
        vm.status[app.nid] = MnoAppsInstances.isConnected(app)
    )
    # Check the number of apps not connected (number of status equals to false)
    vm.hasDisconnectedApps = false of _.countBy(vm.status)

  # Add app modal
  vm.openAddAppModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/organization/add-app-modal/add-app-modal.html'
      controller: 'AddAppModalCtrl'
      controllerAs: 'vm'
      backdrop: 'static'
      windowClass: 'add-app-modal'
      size: 'lg'
      resolve:
        organization: vm.organization
    )
    modalInstance.result.then(
      (organization) ->
        vm.organization = angular.copy(organization)
        vm.updateStatus()
    )

  # Remove app modal
  vm.openRemoveAppModal = (app, index) ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/organization/remove-app-modal/remove-app-modal.html'
      controller: 'RemoveAppModalCtrl'
      controllerAs: 'vm'
      backdrop: 'static'
      windowClass: 'remove-app-modal'
      size: 'md'
      resolve:
        app: app
    )
    modalInstance.result.then(
      (result) ->
        # If the user decide to remove the app
        if result
          vm.organization.active_apps.splice(index, 1)
          vm.updateStatus()
    )

  return vm
