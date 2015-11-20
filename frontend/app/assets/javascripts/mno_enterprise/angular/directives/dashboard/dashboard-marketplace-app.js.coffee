module = angular.module('maestrano.dashboard.dashboard-marketplace-app',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardMarketplaceAppCtrl',[
  '$scope', 'MarketplaceSvc', 'DhbOrganizationSvc','AssetPath','$routeParams',
  ($scope, MarketplaceSvc, DhbOrganizationSvc, AssetPath, $routeParams) ->
    
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.app = {}
    
    #====================================
    # Scope Management
    #====================================
    $scope.initialize = (app) ->
      angular.copy(app,$scope.app)
      $scope.isLoading = false
      
    $scope.backLink = ->
      "#/marketplace"
    
    # Check that the testimonial is not empty
    $scope.isTestimonialShown = (testimonial) ->
      testimonial.text? && testimonial.text.length > 0
    
    $scope.provisionLink = () ->
      "/mnoe/provision/new?apps[]=#{$scope.app.nid}&organization_id=#{DhbOrganizationSvc.getId()}"
    
    #====================================
    # Cart Management
    #====================================
    $scope.cart = cart = {
      isOpen: false
      bundle: {}
      config: {}
    }
    
    # Open the ShoppingCart
    cart.open = ->
      if (d = DhbOrganizationSvc.data) && (o = d.organization) && o.id
        cart.config.organizationId = o.id
      
      cart.bundle = { app_instances: [{app: { id: $scope.app.id }}] }
      cart.isOpen = true
    
    
    #====================================
    # Post-Initialization
    #====================================
    MarketplaceSvc.load().then (marketplace)->
      listApp = _.findWhere(marketplace.apps,{slug: $routeParams.appId })
      listApp ||= _.findWhere(marketplace.apps,{id: parseInt($routeParams.appId) })
      $scope.initialize(listApp)

])

module.directive('dashboardMarketplaceApp', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {},
      templateUrl: TemplatePath['mno_enterprise/dashboard/marketplace/show.html'],
      controller: 'DashboardMarketplaceAppCtrl'
    }
])
