@App.controller 'CreateStep1Controller', ($scope, $document, $state, toastr, MnoeOrganizations, MnoeMarketplace, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.organization = {}
  vm.appSearch = ""

  vm.toggleApp = (app) ->
    app.checked = !app.checked

  vm.submitOrganisation = () ->
    # Is form valid?
    if vm.form.$invalid
      # Check if there is errors that are not from the server
      if !MnoErrorsHandler.onlyServerError(vm.form)
        # Scroll to the top of form
        form = angular.element(document.getElementById('org-form'))
        $document.scrollToElementAnimated(form)
        return

    vm.isLoading = true

    # Reset server errors
    MnoErrorsHandler.resetErrors(vm.form)

    # List of checked apps
    vm.organization.app_nids = _.pluck(_.filter(vm.marketplace.apps, {checked: true}), 'nid')

    MnoeOrganizations.create(vm.organization).then(
      (response) ->
        toastr.success("Organisation #{vm.organization.name} has been successfully created.")
        response = response.data.plain()
        # App to be connected?
        if _.isEmpty(response.organization.active_apps)
          # Go to organization screen
          $state.go('dashboard.home.organization', {orgId: response.organization.id})
        else
          # Go to connect your apps screen
          $state.go('dashboard.customers.create-step-2', {orgId: response.organization.id})
      (error) ->
        $document.scrollTopAnimated(0)
        toastr.error("An error occurred while creating organisation #{vm.organization.name}.")
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  MnoeMarketplace.getApps().then(
    (response) ->
      # Copy the marketplace as we will work on the cached object
      vm.marketplace = angular.copy(response.data)
  )

  return
