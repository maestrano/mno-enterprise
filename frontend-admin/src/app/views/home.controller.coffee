@App.controller 'HomeController', (MnoeUsers) ->
  'ngInject'
  vm = this

  vm.users = {}

  # API calls
  MnoeUsers.list().then(
    (response) ->
      vm.users.list = response
  )

  return
