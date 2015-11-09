angular.module 'frontendAdmin'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'
    $stateProvider
      .state 'dashboard',
        abstract: true
        templateUrl: 'app/views/dashboard.layout.html'
        controller: 'DashboardController'
        controllerAs: 'main'
      .state 'dashboard.home',
        url: '/home'
        templateUrl: 'app/views/home.html'

    $urlRouterProvider.otherwise '/home'
