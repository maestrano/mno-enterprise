module = angular.module('maestrano.user-setup.index',['maestrano.assets'])

module.controller('UserSetupIndexCtrl',[
  '$scope','$http','$q','$filter','$modal','$mdToast','$timeout','$log','AssetPath','Utilities','Miscellaneous','DhbOrganizationSvc','CurrentUserSvc','MarketplaceSvc','TemplatePath',
  ($scope, $http, $q, $filter, $modal, $mdToast, $timeout, $log, AssetPath, Utilities, Miscellaneous, DhbOrganizationSvc, CurrentUserSvc, MarketplaceSvc, TemplatePath) ->
    
    REAL_PROVISIONING_ENABLED = false
    
    #====================================
    # Construction
    #====================================
    $scope.isLoading = true
    $scope.myApps = []
    $scope.selectedCategories = {}
    
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
      ],
      bundleCategories: {
        "Accounting": [
          "Manage your books",
          "Manage multiple currency invoices",
          "Track your finances",
          "Reconcile your bank statements",
          "Manage your inventory",
          "Automate general ledger generation"
        ],
        "Sales and Marketing": [
          "Manage my contacts, customers and suppliers",
          "Automate sales management",
          "Forecast sales",
          "Manage my purchase orders",
          "Create and manage accounts payable & receivable",
          "Manage support tickets"
        ],
        "Content Management": [
          "Create my website",
          "Create a private portal",
          "Organize my files",
          "Create a vault for my files"
        ],
        "Business Operations": [
          "Have an overview on tasks to perform",
          "Schedule an agenda and create milestones",
          "Keep track of my production"
          "Map processes"
          "Design and test my company's processes"
        ],
        "Project Managment": [
          "Automate reminders on projects",
          "Communicate instantly with my collaborators",
          "Manage to do lists",
          "create Gantt charts"
        ],
        "HR": [
          "Manage and automate payroll",
          "Manage recruitment process",
          "Automate absence management",
          "Manage training and development"
        ],
        "Learning Management System": [
          "Create online classes and lessons",
          "Create and manage discussion forum",
          "Grade assignments",
          "Create surveys"
        ],
        "Online Surveying": [
          "Follow up on online survey reports",
          "Collect data through online surveys",
          "Create graphs with your data"
        ]
      },
      recommendations: {
        "Accounting": 'xero',
        "Sales and Marketing": 'vtiger6',
        "Content Management": 'wordpress',
        "Business Operations": 'dolibarr',
        "Project Managment": 'collabtive',
        "HR": 'orangehrm',
        "Learning Management System": 'moodle',
        "Online Surveying": 'limesurvey'
      }
    }
    
    $scope.workflows = {
      step1: -> DhbOrganizationSvc.organization.update($scope.company)
    }
    
    # Scope initialization
    $scope.initialize = ->
      $scope.step = 1
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
      
      # Fetch "next" action or default to resolved promise
      nextAction = $scope.workflows["step#{$scope.step}"]
      unless nextAction
        q = $q.defer()
        q.resolve()
        nextAction = -> q.promise
      
      nextAction().then ->
        $scope.skip()
    
    # Skip the current step - no action performed
    $scope.skip = ->
      $scope.step += 1
      $scope.isLoading = false
    
    $scope.back = ->
      $scope.step -= 1
      $scope.isLoading = false
    
    $scope.finishSetup = ->
      if REAL_PROVISIONING_ENABLED && $scope.myApps.length > 0
        $scope.provisionBasket()
      else
        $scope.redirectToMyspace()
    
    $scope.redirectToMyspace = ->
      window.location.href = "/mnoe/myspace"
    
    $scope.provisionBasket = ->
      q = _.reduce($scope.myApps, ((memo, e) -> "#{memo}&apps[]=#{e.nid}"),"")
      window.location.href = "/mnoe/provision/new?#{q}"
    
    # Return the list of popular apps in the order specified by the configuration array
    $scope.popularApps = ->
      _.map $scope.lists.popularApps, (e) -> _.findWhere($scope.apps, nid: e)
    
    
    # Show a notification message at the top right of the screen
    $scope.showMessageToast = (msg)->
      $mdToast.show(
        $mdToast.simple()
          .content(msg)
          .position("top right")
          .hideDelay(4000)
          .parent(angular.element('.user-setup'))
      )
    
    # Recommend applications based on selected categories
    $scope.recommendedApps = ->
      bla = _.reduce $scope.selectedCategories, (memo, v,k) ->
        memo.push(_.findWhere($scope.apps, nid: $scope.lists.recommendations[k])) if v
        memo
      ,[]
      
    # Add an application to the user basket
    $scope.addAppToBasket = (app) ->
      $scope.showMessageToast("#{app.name} has been successfully added to your free trial!")
      $scope.myApps.push(app) unless $scope.isAppInBasket(app)
    
    # Remove an application from the user basket
    $scope.removeAppFromBasket = (app) ->
      $scope.showMessageToast("#{app.name} has been removed from your free trial")
      if $scope.isAppInBasket
        index = $scope.myApps.indexOf(app)
        $scope.myApps.splice(index, 1)
    
    # Add/remove an application from the user basket
    $scope.toggleAppInBasket = (app) ->
      if $scope.isAppInBasket(app) then $scope.removeAppFromBasket(app) else $scope.addAppToBasket(app)
    
    # Return true if the provided app is in the user basket - false otherwise
    $scope.isAppInBasket = (app) ->
      _.contains($scope.myApps,app)
    
    
    $scope.toggleOrConnect = (app) ->
      if $scope.isAppInBasket(app) then $scope.removeAppFromBasket(app) else $scope.connectApp(app)
    
    # Switch to the connect screen
    $scope.connectApp = (app) ->
      $scope.connectPane.currentApp = app
      $timeout(
        ->
          $scope.connectPane.shown = true
        ,300)
    
    #====================================
    # Connect Pane
    #====================================
    $scope.connectPane = {}
    
    $scope.connectPane.connect = ->
      self = $scope.connectPane
      self.loading = true
      $timeout(
        ->
          $scope.addAppToBasket(self.currentApp)
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