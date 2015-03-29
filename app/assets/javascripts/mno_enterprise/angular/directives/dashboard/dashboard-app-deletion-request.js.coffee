module = angular.module('maestrano.dashboard.dashboard-app-deletion-request',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardAppDeletionRequestCtrl',[
  '$scope','$modal','DashboardAppInstance','DashboardAppsDocument','Utilities',
  ($scope, $modal, DashboardAppInstance, DashboardAppsDocument, Utilities) ->

    init = ->
      $scope.data = DashboardAppsDocument.data["app_instance_#{$scope.appId}"].plan
      $scope.modal = { inProgress:false }
      $scope.sentence = "Please proceed to the deletion of my app and all data it contains"

      $scope.modal.open = ->
        $scope.modal.$instance = $modal.open(templateUrl:'internal-deletion-modal.html',scope:$scope, size:'lg')

      $scope.modal.close = ->
        $scope.modal.$instance.close()

      $scope.proceed = ->
        $scope.modal.loading = true
        DashboardAppInstance.terminate($scope.appId).then(
          (success) ->
            $scope.modal.loading = false
            $scope.modal.close()
          ,(error) ->
            $scope.modal.loading = false
            $scope.modal.errors = Utilities.processRailsError(error)
        )

      # Open modal
      $scope.$watch(( -> $scope.openModal), ->
        if $scope.openModal > 0 then $scope.modal.open()
      )

    $scope.$watch DashboardAppsDocument.getId, (val) ->
      $scope.loading = true
      if val?
        DashboardAppsDocument.load(val).then ->
          init()

])

module.directive('dashboardAppDeletionRequest', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        appId:'@'
        openModal:'='
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/app_deletion.html'],
      controller: 'DashboardAppDeletionRequestCtrl'
    }
])
