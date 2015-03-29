module = angular.module('maestrano.components.mno-sync-config',['maestrano.assets'])

#============================================
# Component 'Sync config'
#============================================
module.controller('MnoSyncConfigCtrl',[
  '$scope', '$http', '$window', '$modal', ($scope, $http, $window, $modal) ->
    $scope.modal = {}
    $scope.modal.isOpen = false

    $scope.modal.toggle = ->
      if $scope.modal.isOpen
        $scope.modalInstance.close()
      else
        $scope.modalInstance = $modal.open(templateUrl: 'internal-sync-config-modal.html', scope: $scope)
      $scope.modal.isOpen = !$scope.modal.isOpen

    $scope.sync = {}
    $scope.sync.go = ->
      url = "/webhook/sync/#{$scope.instanceUid}/perform?mode=#{$scope.sync.mode}"
      window.location = url

    $scope.sync.mode = "PULL-PUSH"

    $scope.toggleFun = $scope.modal.toggle

])

module.directive('mnoSyncConfig', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        toggleFun: '='
        instanceUid: '@'
        appName: '='
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/sync_config.html'],
      controller: 'MnoSyncConfigCtrl',
  }
])
