@App.controller 'FinanceController', ($filter, MnoeInvoices, MnoeTenantInvoices, MnoeOrganizations) ->
  'ngInject'
  vm = this

  vm.invoices = {}
  vm.organizations = {}

  # API calls
  MnoeInvoices.currentBillingAmount().then(
    (response) ->
      vm.invoices.currentBillingAmount = response
  )

  MnoeTenantInvoices.list().then(
    (response) ->
      vm.invoices.tenantInvoices = response
      vm.invoices.tenantInvoices = $filter('orderBy')(vm.invoices.tenantInvoices, '-started_at')
  )

  MnoeOrganizations.inArrears().then(
    (response) ->
      vm.organizations.inArrears = response
      # Humanize (payment_failed -> Payment failed)
      _.forEach(vm.organizations.inArrears, (org) ->
        org.category = _.capitalize(org.category.replace("_", " "))
      )
      vm.organizations.inArrears = $filter('orderBy')(vm.organizations.inArrears, '-started_at')
  )

  return
