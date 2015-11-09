angular.module 'frontendAdmin'
  .controller 'DashboardController', ($timeout, toastr) ->
    'ngInject'
    main = this

    main.user = 'Alex'
    main.toggle = true

    main.toggleSidebar = () ->
      main.toggle = !main.toggle

    return
