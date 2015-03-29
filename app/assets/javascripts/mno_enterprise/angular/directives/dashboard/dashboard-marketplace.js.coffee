module = angular.module('maestrano.dashboard.dashboard-marketplace',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardMarketplaceCtrl',[
  '$scope', 'MarketplaceSvc', 'AssetPath'
  ($scope, MarketplaceSvc, AssetPath) ->
    
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.selectedCategory = ''
    $scope.searchTerm = ''
    $scope.appFilter = ''
    
    #====================================
    # Scope Management
    #====================================
    $scope.initialize = (marketplace)->
      $scope.categories = marketplace.categories
      $scope.apps = marketplace.apps
      $scope.isLoading = false
    
    $scope.linkFor = (app) ->
      "#/marketplace/#{app.id}"
    
    $scope.appsFilter = (app) ->
      if ($scope.searchTerm? && $scope.searchTerm.length > 0) || !$scope.selectedCategory
        return true
       else
        return _.contains(app.categories,$scope.selectedCategory)
    
    #====================================
    # Post-Initialization
    #====================================
    MarketplaceSvc.load().then (marketplace)->
      $scope.initialize(marketplace)

])

module.directive('dashboardMarketplace', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {},
      templateUrl: TemplatePath['mno_enterprise/dashboard/marketplace/index.html'],
      controller: 'DashboardMarketplaceCtrl'
    }
])
