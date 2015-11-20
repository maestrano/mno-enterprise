@App.controller 'DashboardController', ->
  'ngInject'
  main = this

  main.toggle = true

  main.toggleSidebar = () ->
    main.toggle = !main.toggle

  return
