module = angular.module('maestrano.dashboard.dashboard-organization-billing',['maestrano.assets'])

#============================================
# Current Billing Directive
#============================================
module.controller('DashboardOrganizationBillingCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'Utilities','AssetPath','Miscellaneous'
  ($scope, $window, DhbOrganizationSvc, Utilities,AssetPath,Miscellaneous) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.billing = {}

    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    $scope.initialize = (billing) ->
      angular.copy(billing,$scope.billing)
      $scope.isLoading = false

    $scope.isCreditShown = () ->
      b = $scope.billing
      b &&
      b.credit &&
      b.credit.value > 0

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      $scope.isLoading = true
      if val?
        DhbOrganizationSvc.load().then (organization)->
          $scope.initialize(organization.billing)
])

module.directive('dashboardOrganizationBilling', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/organization/billing.html'],
      controller: 'DashboardOrganizationBillingCtrl'
    }
])
