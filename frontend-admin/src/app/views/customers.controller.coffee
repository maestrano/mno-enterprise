@App.controller 'CustomersController', (MnoeUsers, MnoeOrganizations, MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

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
