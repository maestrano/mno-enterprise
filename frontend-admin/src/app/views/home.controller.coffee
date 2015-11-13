@App.controller 'HomeController', (MnoeUsers, MnoeOrganizations, MnoeInvoices) ->
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

  MnoeInvoices.lastInvoicingAmount().then(
    (response) ->
      vm.invoices.currentBilling = response
  )

  MnoeInvoices.outstandingAmount().then(
    (response) ->
      vm.invoices.outstandingAmount = response
  )

  return
