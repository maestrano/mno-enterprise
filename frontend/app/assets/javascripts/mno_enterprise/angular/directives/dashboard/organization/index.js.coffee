module = angular.module('maestrano.dashboard.dashboard-organization-index',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationIndexCtrl',[
  '$scope', 'DhbOrganizationSvc', 'AssetPath'
  ($scope, DhbOrganizationSvc, AssetPath) ->
    
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.tabs = {
      billing: false,
      members: false,
      teams: false,
      settings: false
    }
    
    #====================================
    # Scope Management
    #====================================
    $scope.initialize = ->
      $scope.isLoading = false
      if $scope.isBillingShown()
        $scope.tabs.billing = true
      else
        $scope.tabs.members = true
    
    $scope.isTabSetShown = ->
      !$scope.isLoading && (
        DhbOrganizationSvc.user.isSuperAdmin() || DhbOrganizationSvc.user.isAdmin())
    
    $scope.isBillingShown = ->
      DhbOrganizationSvc.user.isSuperAdmin()
    
    $scope.isSettingsShown = ->
      DhbOrganizationSvc.user.isSuperAdmin()
    
    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      $scope.isLoading = true
      if val?
        DhbOrganizationSvc.load().then (organization)->
          $scope.initialize()

])

module.directive('dashboardOrganizationIndex', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/organization/index.html'],
      controller: 'DashboardOrganizationIndexCtrl'
    }
])
