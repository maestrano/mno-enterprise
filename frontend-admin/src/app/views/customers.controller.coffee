@App.controller 'CustomersController', (MnoeUsers, MnoeOrganizations, MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

  MnoeUsers.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.users.totalCount = response.headers('x-total-count')
      )
  )

  MnoeOrganizations.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.organizations.totalCount = response.headers('x-total-count')
      )
  )

  return
