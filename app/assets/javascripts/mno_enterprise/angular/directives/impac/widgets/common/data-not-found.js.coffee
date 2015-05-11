module = angular.module('maestrano.impac.widgets.common.data-not-found',['maestrano.assets'])

module.directive('widgetCommonDataNotFound', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/common/data-not-found.html'],
  }
])