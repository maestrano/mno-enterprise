@App.controller 'DashboardController', ->
  'ngInject'
  main = this

  main.user = 'Alex Jarnoux'
  main.toggle = true

  main.toggleSidebar = () ->
    main.toggle = !main.toggle

  return
