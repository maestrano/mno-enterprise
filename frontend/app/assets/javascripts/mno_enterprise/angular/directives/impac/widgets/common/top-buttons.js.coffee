module = angular.module('maestrano.impac.widgets.common.top-buttons',['maestrano.assets'])

module.controller('WidgetCommonTopButtonsCtrl',
  ['$scope', '$rootScope', 'ImpacDashboardingSvc', 'AssetPath',
  ($scope, $rootScope, ImpacDashboardingSvc, AssetPath) ->

    w = $scope.parentWidget

    $scope.showCloseActive = false
    $scope.showEditActive = false
    $scope.closeWidgetButtonImage = AssetPath['mno_enterprise/impac/close-widget.png']
    $scope.closeWidgetButtonImageActive = AssetPath['mno_enterprise/impac/close-widget-pink.png']

    w.isEditMode = false

    $scope.deleteWidget = ->
      ImpacDashboardingSvc.widgets.delete(w.id, w.parentDashboard).then(
        (->)
        ,(errors) ->
          w.errors = Utilities.processRailsError(errors)
      )
      # Refresh needed to display the 'add a widget' message in case of no widget
      # ).finally(-> ImpacDashboardingSvc.load(true))

    $scope.toogleEditMode = ->
      if !w.isLoading
        if w.isEditMode
          # Like a press on 'Cancel' button
          w.initSettings()
        else
          # Otherwise, we pass in edit mode
          w.isEditMode = true
])

module.directive('widgetCommonTopButtons', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/common/top-buttons.html'],
    controller: 'WidgetCommonTopButtonsCtrl'
  }
])