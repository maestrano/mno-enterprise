#
# KPI Currency Body Directive
#
@App.directive('rdKpiBodyCurrency', ->
  requires: '^rdKpi',
  scope: {
    currency: '@',
    amount: '@'
  },
  templateUrl: 'app/components/rdash-angular/kpi-body-currency.html',
  restrict: 'E'
)
