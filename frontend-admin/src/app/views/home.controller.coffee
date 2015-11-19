@App.controller 'HomeController', (moment, MnoeUsers, MnoeOrganizations, MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

  # TODO: endpoint in backend
  countNewUsersLastMonth = () ->
    _.countBy(vm.users.list, (u) ->
      dateFrom = moment(_.now()).subtract(1,'months').startOf('month')
      dateTo = moment(_.now()).subtract(1,'months').endOf('month')
      moment(u.created_at).isBetween(dateFrom, dateTo)
    )

  # TODO: endpoint in backend
  countOrgsWithACreditCard = () ->
    _.countBy(vm.organizations.list, (o) ->
      o.credit_card.presence
    )

  # API calls
  MnoeUsers.list().then(
    (response) ->
      vm.users.list = response
      vm.users.countNewLastMonth = countNewUsersLastMonth().true || 0
  )

  MnoeOrganizations.list().then(
    (response) ->
      vm.organizations.list = response
      vm.organizations.countWithCC = countOrgsWithACreditCard().true || 0
  )

  MnoeInvoices.lastInvoicingAmount().then(
    (response) ->
      vm.invoices.lastInvoicingAmount = response
  )

  MnoeInvoices.outstandingAmount().then(
    (response) ->
      vm.invoices.outstandingAmount = response
  )

  return
