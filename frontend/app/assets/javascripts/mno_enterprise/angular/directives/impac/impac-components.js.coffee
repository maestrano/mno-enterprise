# This main module requires all the sub-modules that should compose it
# This pattern allows us to split a fat module in several files
analyticsComponents = angular.module('maestrano.impac', [
  # Analytics Section
  'maestrano.impac.index',
  'maestrano.impac.widget',
  'maestrano.impac.widgets.accounts.accounting-values',
  'maestrano.impac.widgets.accounts.assets-summary',
  'maestrano.impac.widgets.accounts.balance',
  'maestrano.impac.widgets.accounts.comparison',
  'maestrano.impac.widgets.accounts.custom-calculation',
  'maestrano.impac.widgets.accounts.expenses-revenue',
  'maestrano.impac.widgets.accounts.payable-receivable',
  'maestrano.impac.widgets.invoices.list',
  'maestrano.impac.widgets.invoices.summary',
  'maestrano.impac.widgets.settings.account',
  'maestrano.impac.widgets.settings.accounts-list',
  'maestrano.impac.widgets.settings.chart-filters',
  'maestrano.impac.widgets.settings.formula',
  'maestrano.impac.widgets.settings.hist-mode',
  'maestrano.impac.widgets.settings.organizations',
  'maestrano.impac.widgets.settings.time-range',
  'maestrano.impac.widgets.common.chart'
  'maestrano.impac.widgets.common.data-not-found',
  'maestrano.impac.widgets.common.editable-title',
  'maestrano.impac.widgets.common.top-buttons',
  'ui.sortable',
  'ui.bootstrap.tooltip',
  ]
)

