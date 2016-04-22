@App.controller 'CreateStep2Controller', ($stateParams, MnoeOrganizations, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.mnoAppInstances = MnoAppsInstances

  vm.orgId = $stateParams.orgId

  vm.isLoading = true
  MnoeOrganizations.get($stateParams.orgId).then(
    (response) ->
      vm.organization = response.data
  ).finally(-> vm.isLoading = false)

  return
