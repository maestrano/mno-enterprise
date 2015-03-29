module = angular.module('maestrano.dashboard.dashboard-organization-invoices',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationInvoicesCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'Utilities','AssetPath'
  ($scope, $window, DhbOrganizationSvc, Utilities, AssetPath) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.invoices = []
    
    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    $scope.initialize = (invoices) ->
      angular.copy(invoices,$scope.invoices)
      $scope.isLoading = false
    
    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      $scope.isLoading = true
      if val?
        DhbOrganizationSvc.load().then (organization)->
          $scope.initialize(organization.invoices)
])

module.directive('dashboardOrganizationInvoices', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['dashboard/organization/invoices.html'],
      controller: 'DashboardOrganizationInvoicesCtrl'
    }
])