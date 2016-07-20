@App.config ($stateProvider, $urlRouterProvider) ->
  'ngInject'
  $stateProvider
    .state 'dashboard',
      abstract: true,
      templateUrl: 'app/views/dashboard.layout.html'
      controller: 'DashboardController'
      controllerAs: 'main'
    .state 'dashboard.home',
      data:
        pageTitle:'Home'
      url: '/home'
      templateUrl: 'app/views/home/home.html'
      controller: 'HomeController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Home'
    .state 'dashboard.home.user',
      data:
        pageTitle:'User'
      url: '^/user/:userId'
      views: '@dashboard':
        templateUrl: 'app/views/user/user.html'
        controller: 'UserController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'User'
    .state 'dashboard.home.organization',
      data:
        pageTitle:'Organization'
      url: '^/organization/:orgId'
      views: '@dashboard':
        templateUrl: 'app/views/organization/organization.html'
        controller: 'OrganizationController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Organisation'
    .state 'dashboard.finance',
      data:
        pageTitle:'Finance'
      url: '/finance'
      templateUrl: 'app/views/finance/finance.html'
      controller: 'FinanceController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Finance'
    .state 'dashboard.staff',
      data:
        pageTitle:'Staff'
      url: '/staff' #:staffId
      templateUrl: 'app/views/staff/staff.html'
      controller: 'StaffController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Staff'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
    .state 'dashboard.customers',
      data:
        pageTitle:'Customers'
      url: '/customers'
      templateUrl: 'app/views/customers/customers.html'
      controller: 'CustomersController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Customers'
    .state 'dashboard.customers.create-step-1',
      url: '^/customers/create-customer'
      views: '@dashboard':
        templateUrl: 'app/views/customers/create-step-1/create-step-1.html'
        controller: 'CreateStep1Controller'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Create a new customer'
    .state 'dashboard.customers.create-step-2',
      url: '^/customers/:orgId/connect-apps'
      views: '@dashboard':
        templateUrl: 'app/views/customers/create-step-2/create-step-2.html'
        controller: 'CreateStep2Controller'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'Connect cloud apps'

  $urlRouterProvider.otherwise '/home'
