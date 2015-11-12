@App.controller 'HomeController', (MnoeUsers) ->
  'ngInject'
  vm = this

  # Variables initialization
  vm.users =
    list: []
    search: ''

  # API calls
  MnoeUsers.list().then(
    (response) ->
      vm.users.list = response
  )

  return
