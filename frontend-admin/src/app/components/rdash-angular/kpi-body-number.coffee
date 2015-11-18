#
# KPI Currency Body Directive
#
@App.directive('rdKpiBodyNumber', ->
  requires: '^rdKpi',
  scope: {
    number: '@'
  },
  templateUrl: 'app/components/rdash-angular/kpi-body-number.html',
  restrict: 'E'
)
