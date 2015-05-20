module = angular.module('maestrano.user-setup.index',['maestrano.assets'])

module.controller('UserSetupIndexCtrl',[
  '$scope','$http','$q','$filter','$modal','$log','AssetPath','Utilities','Miscellaneous','DhbOrganizationSvc','CurrentUserSvc','MarketplaceSvc','TemplatePath',
  ($scope, $http, $q, $filter, $modal, $log, AssetPath, Utilities, Miscellaneous, DhbOrganizationSvc, CurrentUserSvc, MarketplaceSvc, TemplatePath) ->
    
    #====================================
    # Construction
    #====================================
    $scope.isLoading = true
    
    $scope.lists = {
      industries: [
        "Agriculture",
        "Arts",
        "Construction",
        "Consumer Goods",
        "Corporate",
        "Educational",
        "Finance",
        "Government",
        "High Tech",
        "Legal",
        "Manufacturing",
        "Media",
        "Medical",
        "Non-Profit",
        "Recreational",
        "Service Transportation",
        "Other",
      ],
      sizes: [
        {label: "1 to 5 employees", value: "1 - 5"},
        {label: "6 to 10 employees", value: "6 - 10"},
        {label: "11 to 50 employees", value: "11 - 50"},
        {label: "51 to 200 employees", value: "51 - 200"},
        {label: "+200 employees", value: "+200"},
      ],
      popularApps: [
        'xero','quickbooks','myob','vtiger6','sugarcrm','wordpress','timetrex','simpleinvoices','orangehrm', 'prestashop'
      ]
    }
    
    # Scope initialization
    $scope.initialize = ->
      $scope.step = 2
      $scope.locals = {}
      $scope.user = CurrentUserSvc.document.current_user
      $scope.company = DhbOrganizationSvc.data.organization
      $scope.apps = MarketplaceSvc.data.apps
      $scope.isLoading = false
    
    #====================================
    # Functions
    #====================================
    $scope.next = ->
      $scope.isLoading = true
      DhbOrganizationSvc.organization.update($scope.company).then ->
        $scope.step += 1
        $scope.isLoading = false
    
    $scope.skip = ->
      $scope.step += 1
    
    $scope.popularApps = ->
      _.map $scope.lists.popularApps, (e) -> _.findWhere($scope.apps, nid: e)
    
    #====================================
    # Initialization
    #====================================
    CurrentUserSvc.loadDocument().then ->
      DhbOrganizationSvc.configure(id: CurrentUserSvc.document.current_user.organizations[0].id)
      $q.all([DhbOrganizationSvc.load(),MarketplaceSvc.load()]).then ->
        $scope.initialize()
])

module.directive('userSetupIndex', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'AE',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/user-setup/index.html'],
      controller: 'UserSetupIndexCtrl'
    }
])