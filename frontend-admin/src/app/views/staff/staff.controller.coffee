@App.controller 'StaffController', ($filter, $stateParams, $uibModal, toastr, MnoeUsers, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.staff =
    # Display staff creation modal
    createModal: ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/staff/create-staff-modal/create-staff.html'
        controller: 'CreateStaffController'
        controllerAs: 'vm'
      )

  vm.displayed = []

  vm.callServer = (tableState) ->
    console.log (tableState)
    vm.isLoading = false

  return vm
