#
# KPI Directive
#
@App.directive('rdKpi', ->
  transclude: true,
  scope:
    icon: '@'
    description: '@'
    link: '@'
    loading: '=?'
  templateUrl: 'app/components/rdash-angular/kpi.html',
  restrict: 'EA'
)
