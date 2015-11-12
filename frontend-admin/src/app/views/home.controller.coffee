@App.controller 'HomeController', (MnoeUsers, MnoeOrganizations) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}

  # API calls
  MnoeUsers.list().then(
    (response) ->
      vm.users.list = response
  )

  MnoeOrganizations.list().then(
    (response) ->
      vm.organizations.list = response
  )

  return
