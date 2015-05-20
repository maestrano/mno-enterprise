module = angular.module('maestrano.user-setup.index',['maestrano.assets'])

module.controller('UserSetupIndexCtrl',[
  '$scope','$http','$q','$filter','$modal','$mdToast','$timeout','$log','AssetPath','Utilities','Miscellaneous','DhbOrganizationSvc','CurrentUserSvc','MarketplaceSvc','TemplatePath',
  ($scope, $http, $q, $filter, $modal, $mdToast, $timeout, $log, AssetPath, Utilities, Miscellaneous, DhbOrganizationSvc, CurrentUserSvc, MarketplaceSvc, TemplatePath) ->
    
    #====================================
    # Construction
    #====================================
    $scope.isLoading = true
    $scope.myApps = []
    
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
    # Go to the next step - potentially perform an action
    $scope.next = ->
      $scope.isLoading = true
      DhbOrganizationSvc.organization.update($scope.company).then ->
        $scope.step += 1
        $scope.isLoading = false
    
    # Skip the current step - no action performed
    $scope.skip = ->
      $scope.step += 1
    
    # Return the list of popular apps in the order specified by the configuration array
    $scope.popularApps = ->
      _.map $scope.lists.popularApps, (e) -> _.findWhere($scope.apps, nid: e)
    
    
    $scope.showMessageToast = (msg)->
      $mdToast.show(
        $mdToast.simple()
          .content(msg)
          .position("top right")
          .hideDelay(4000)
          .parent(angular.element('.user-setup'))
      )
    
    #====================================
    # Connect Pane
    #====================================
    $scope.connectPane = {}
    
    # Switch to the connect screen
    $scope.connectApp = (app) ->
      $scope.connectPane.currentApp = app
      $timeout(
        ->
          $scope.connectPane.shown = true
        ,300)
    
    $scope.connectPane.connect = ->
      self = $scope.connectPane
      self.loading = true
      $timeout(
        ->
          $scope.showMessageToast("#{self.currentApp.name} has been successfully added to your free trial!")
          $scope.myApps.push(self.currentApp)
          self.cancel()
        , 2000)
      
    $scope.connectPane.cancel = ->
      self = $scope.connectPane
      self.loading = false
      self.shown = false
      self.currentApp = undefined
    
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