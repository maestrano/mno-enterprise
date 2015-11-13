@App.controller 'OrganizationController', ($stateParams, MnoeOrganizations) ->
  'ngInject'
  vm = this

  # Get the user
  MnoeOrganizations.get($stateParams.orgId).then(
    (response) ->
      vm.organization = response
  )

  return
