@App.controller 'HomeController', (moment, MnoeUsers, MnoeOrganizations, MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

  # API calls
  MnoeUsers.count().then(
    (response) ->
      vm.users.kpi = response.data
  )

  MnoeOrganizations.count().then(
    (response) ->
      vm.organizations.kpi = response.data
  )

  MnoeInvoices.lastInvoicingAmount().then(
    (response) ->
      vm.invoices.lastInvoicingAmount = response.data
  )

  MnoeInvoices.outstandingAmount().then(
    (response) ->
      vm.invoices.outstandingAmount = response.data
  )

  return
