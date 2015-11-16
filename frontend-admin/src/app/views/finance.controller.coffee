@App.controller 'FinanceController', ($filter, MnoeInvoices, MnoeTenantInvoices) ->
  'ngInject'
  vm = this

  vm.invoices = {}

  # API calls
  MnoeInvoices.currentBillingAmount().then(
    (response) ->
      vm.invoices.currentBillingAmount = response
  )

  MnoeTenantInvoices.list().then(
    (response) ->
      vm.invoices.tenantInvoices = response
      $filter('orderBy')(vm.invoices.tenantInvoices, '-started_at')
  )

  return
