@App.config ($stateProvider, $urlRouterProvider) ->
  'ngInject'
  $stateProvider
    .state 'dashboard',
      abstract: true,
      templateUrl: 'app/views/dashboard.layout.html'
      controller: 'DashboardController'
      controllerAs: 'main'
    .state 'dashboard.home',
      url: '/home'
      templateUrl: 'app/views/home.html'
      controller: 'HomeController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Home'
    .state 'dashboard.home.user',
      url: '^/user/:userId'
      views: '@dashboard':
        templateUrl: 'app/views/user.html'
        controller: 'UserController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'User'
    .state 'dashboard.finance',
      url: '/finance'
      templateUrl: 'app/views/finance.html'
      controller: 'FinanceController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Finance'

  $urlRouterProvider.otherwise '/home'
