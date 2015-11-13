@App.controller 'FinanceController', (MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.invoices = {}

  # API calls
  MnoeInvoices.currentBillingAmount().then(
    (response) ->
      vm.invoices.currentBillingAmount = response
  )

  return
