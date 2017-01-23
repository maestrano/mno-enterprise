@App.controller 'AddAppModalCtrl', ($scope, $uibModalInstance, $window, MnoeMarketplace, MnoeOrganizations, organization, toastr) ->
  'ngInject'
  vm = this

  vm.modal_height = ($window.innerHeight - 200) + "px"
  vm.selectedApp = {}
  vm.organization = angular.copy(organization)
  vm.loading = {
    modal: true
    apps: false
  }
  vm.displayError = false

  # Get the list of all the apps available to the market place
  MnoeMarketplace.getApps().then(
    (response) ->
      vm.marketplace = angular.copy(response.data.plain())
      activeAppNids = _.map(organization.active_apps, 'nid')

      # Filter the app list to remove the ones already activated
      vm.marketplace.filtered_apps = _.filter(vm.marketplace.apps, (app) ->
        return app if not _.includes(activeAppNids, app.nid)
      )
  ).finally(-> vm.loading.modal = false)

  # Select or deselect an app
  vm.toggleApp = (app) ->
    app.checked = !app.checked

  # Close the error banner
  vm.closeError = ->
    vm.displayError = false

  # Add a list of apps to the current organization
  vm.addApps = ->
    vm.loading.apps = true
    vm.appNidsToAdd = _.map(_.filter(vm.marketplace.apps, {checked: true}), 'nid')

    # List of checked apps
    vm.organization.app_nids = _.union(
      vm.appNidsToAdd, _.map(organization.active_apps, 'nid')
    )

    # Close the modal is no apps were selected
    if vm.appNidsToAdd.length == 0
      vm.closeModal()
      return

    MnoeOrganizations.update(vm.organization).then(
      (success) ->
        # Get the number of active apps
        nb_active_apps = success.data.plain().organization.active_apps.length
        nb_apps_to_add = vm.organization.app_nids.length

        # Update the active apps list
        vm.organization = success.data.plain().organization

        # Apps successfully added, close modal
        if nb_active_apps == nb_apps_to_add
          vm.closeModal()
        else  # Some apps were not added
          vm.displayError = true
          active_apps_nids = if active_apps? then _.map(active_apps, 'nid') else []
          # Remove all the apps successfully added from the filtered app list
          _.map(_.intersection(vm.appNidsToAdd, active_apps_nids),
            (app_nid) ->
              _.remove(vm.marketplace.filtered_apps, {
                nid: app_nid
              })
          )

          vm.ListOfApps = _.map(_.difference(vm.appNidsToAdd, active_apps_nids),
            (app_nid) ->
              _.find(vm.marketplace.filtered_apps, {
                nid: app_nid
              }).name
          )

      (error) ->
        toastr.error("We could not process your request, please try again.", {preventDuplicates: false})

    ).finally(-> vm.loading.apps = false)

  # "Close" the modal and return the details of the organization
  vm.closeModal = ->
    $uibModalInstance.close(vm.organization)

  return
