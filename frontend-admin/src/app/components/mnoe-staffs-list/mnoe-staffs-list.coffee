#
# Mnoe organizations List
#
@App.component('mnoeStaffsList', {
  templateUrl: 'app/components/mnoe-staffs-list/mnoe-staffs-list.html',
  bindings: {
    view: '@',
  }
  controller: ($filter, $log, MnoeUsers, MnoConfirm, MnoeObservables, ADMIN_ROLES, OBS_KEYS, toastr) ->
    vm = this

    vm.listOfStaff = []

    # Manage sorting, search and pagination
    vm.callServer = (tableState) ->
      sort   = updateSort (tableState.sort)
      search = updateSearch (tableState.search)

      fetchStaffs(vm.staff.nbItems, vm.staff.offset, sort, search)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "surname"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update staff sort
      vm.staff.sort = sort
      return sort

    # Update searching parameters
    updateSearch = (searchingState = {}) ->
      search = {}
      if searchingState.predicateObject
        for attr, value of searchingState.predicateObject
          if attr == "admin_role"
            search[ 'where[admin_role.in][]' ] = [value]
          else
            search[ 'where[' + attr + '.like]' ] = value + '%'

      # Update staff sort
      vm.staff.search = search
      return search

    # Widget state
    vm.state = vm.view

    vm.staff =
      editmode: []
      search: {}
      sort: "surname"
      nbItems: 10
      page: 1
      roles: ADMIN_ROLES
      pageChangedCb: (nbItems, page) ->
        vm.staff.nbItems = nbItems
        vm.staff.page = page
        offset = (page  - 1) * nbItems
        fetchStaffs(nbItems, offset)

      update: (staff) ->
        MnoeUsers.updateStaff(staff).then(
          (response) ->
            updateSort()
            updateSearch()
            # Remove the edit mode for this user
            delete vm.staff.editmode[staff.id]
          (error) ->
            # Display an error
            $log.error('Error while saving user', error)
            toastr.error('An error occurred while saving the user.')
        )

      remove: (staff) ->
        modalOptions =
          closeButtonText: 'Cancel'
          actionButtonText: 'Delete Team Member'
          headerText: 'Delete ' + staff.name + ' ' + staff.surname + '?'
          bodyText: 'Are you sure you want to delete this team member?'

        MnoConfirm.showModal(modalOptions).then( ->
          console.log 'Remove staff role:' + staff
          MnoeUsers.removeStaff(staff.id).then( ->
            toastr.success("#{staff.name} #{staff.surname} has been successfully removed.")
          )
        )

    # Fetch staffs
    fetchStaffs = (limit, offset, sort = vm.staff.sort, search = vm.staff.search) ->
      vm.staff.loading = true
      return MnoeUsers.staffs(limit, offset, sort, search).then(
        (response) ->
          vm.staff.totalItems = response.headers('x-total-count')
          vm.listOfStaff = response.data
      ).finally(-> vm.staff.loading = false)

    # Initial call and start the listeners
    fetchStaffs(vm.staff.nbItems, 0).then( ->
      # Notify me if a user is added
      MnoeObservables.registerCb(OBS_KEYS.staffAdded, ->
        fetchStaffs(vm.staff.nbItems, vm.staff.offset)
      )
      # Notify me if the list changes
      MnoeObservables.registerCb(OBS_KEYS.staffChanged, ->
        fetchStaffs(vm.staff.nbItems, vm.staff.offset)
      )
    )
    return

})
