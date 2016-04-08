@App.controller 'OrganizationController', ($filter, $stateParams, MnoeOrganizations) ->
  'ngInject'
  vm = this

  # Get the organization
  MnoeOrganizations.get($stateParams.orgId).then(
    (response) ->
      vm.organization = response.data
      vm.organization.invoices = $filter('orderBy')(vm.organization.invoices, '-started_at')
  )

  return
