module = angular.module('maestrano.impac.widgets.common.editable-title',['maestrano.assets'])

module.controller('WidgetCommonEditableTitleCtrl',
  ['$scope', 'ImpacDashboardingSvc',
  ($scope, ImpacDashboardingSvc) ->

    w = $scope.parentWidget

    $scope.updateName = ->
      if w.name.length == 0
        w.name = w.originalName
        return "Incorrect name"
      else
        data = { name: w.name }
        ImpacDashboardingSvc.widgets.update(w,data).then(
          (success)->
            w.originalName = w.name
            angular.extend(w, success.data)
          , ->
            w.name = w.originalName
        )
])

module.directive('widgetCommonEditableTitle', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/common/editable-title.html'],
    controller: 'WidgetCommonEditableTitleCtrl'
  }
])