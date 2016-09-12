@App.controller 'FinanceController', ($filter, MnoeInvoices, MnoeTenantInvoices, MnoeOrganizations) ->
  'ngInject'
  vm = this

  vm.invoices = {}
  vm.organizations = {}

  # API calls
  MnoeInvoices.currentBillingAmount().then(
    (response) ->
      vm.invoices.currentBillingAmount = response.data
  )
  MnoeInvoices.lastInvoicingAmount().then(
    (response) ->
      vm.invoices.lastInvoicingAmount = response.data
  )
  MnoeInvoices.lastPortfolioAmount().then(
    (response) ->
      vm.invoices.lastPortfolioAmount = response.data
  )
  MnoeInvoices.lastCommissionAmount().then(
    (response) ->
      vm.invoices.lastCommissionAmount = response.data
  )

  MnoeTenantInvoices.list().then(
    (response) ->
      vm.invoices.tenantInvoices = response.data
      vm.invoices.tenantInvoices = $filter('orderBy')(vm.invoices.tenantInvoices, '-started_at')
  )

  MnoeOrganizations.inArrears().then(
    (response) ->
      vm.organizations.inArrears = response.data
      # TODO: in backend
      # Humanize (payment_failed -> Payment failed)
      _.forEach(vm.organizations.inArrears, (org) ->
        org.category = _.capitalize(org.category.replace("_", " "))
      )
      vm.organizations.inArrears = $filter('orderBy')(vm.organizations.inArrears, '-started_at')
  )

  return
