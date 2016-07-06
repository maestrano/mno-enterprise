@App.controller 'DashboardController', ($scope, $cookies, $sce, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, STAFF_PAGE_AUTH) ->
  'ngInject'
  main = this

  main.errorHandler = MnoErrorsHandler
  main.staffPageAuthorized = STAFF_PAGE_AUTH

  main.trustSrc = (src) ->
    $sce.trustAsResourceUrl(src)

  mobileView = 992

  main.getWidth = ->
    window.innerWidth

  $scope.$watch main.getWidth, (newValue) ->
    if newValue >= mobileView
      if angular.isDefined($cookies.get('admin_platform_toggle'))
        main.toggle = if !$cookies.get('admin_platform_toggle') then false else true
      else
        main.toggle = true
    else
      main.toggle = false

  main.toggleSidebar = () ->
    main.toggle = !main.toggle
    $cookies.put('admin_platform_toggle', main.toggle)

  window.onresize = () ->
    $scope.$apply()

  # Preload data to be reused in the app
  # Marketplace is cached
  # MnoeMarketplace.getApps()

  MnoeCurrentUser.getAdminRole().then(
    # Display the layout
    main.user = MnoeCurrentUser.user
  )

  return
