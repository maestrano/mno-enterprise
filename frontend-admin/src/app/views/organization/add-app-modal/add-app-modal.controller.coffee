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
      activeAppNids = _.pluck(organization.active_apps, 'nid')

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
    vm.appNidsToAdd = _.pluck(_.filter(vm.marketplace.apps, {checked: true}), 'nid')

    # List of checked apps
    vm.organization.app_nids = _.union(
      vm.appNidsToAdd, _.pluck(organization.active_apps, 'nid')
    )

    # Close the modal is no apps were selected
    if vm.appNidsToAdd.length == 0
      vm.closeModal()
      return

    MnoeOrganizations.update(vm.organization).then(
      (success) ->
        # Get the list of active apps
        active_apps = success.data.plain().organization.active_apps

        # Some apps were not added
        if active_apps.length < vm.organization.app_nids.length
          vm.displayError = true
          active_apps_nids = _.pluck(active_apps, 'nid')
          # Remove all the apps successfully added from the filtered app list
          _.map(_.intersection(vm.appNidsToAdd, active_apps_nids),
            (app_nid) ->
              _.remove(vm.marketplace.filtered_apps, {
                nid: app_nid
              })
          )

          vm.ListOfApps = _.pluck(_.map(_.difference(vm.appNidsToAdd, active_apps_nids),
            (app_nid) ->
              _.find(vm.marketplace.filtered_apps, {
                nid: app_nid
              })
          ), 'name')

          # Update the active apps list
          vm.organization = success.data.plain().organization
        else  # Apps successfully added, close modal
          vm.organization = success.data.plain().organization
          vm.closeModal()
      (error) ->
        toastr.error("We could not process your request, please try again.", {preventDuplicates: false})

    ).finally(-> vm.loading.apps = false)

  # "Close" the modal and return the details of the organization
  vm.closeModal = ->
    $uibModalInstance.close(vm.organization)

  return
