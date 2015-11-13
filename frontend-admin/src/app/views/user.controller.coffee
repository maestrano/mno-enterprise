@App.controller 'UserController', ($stateParams, MnoeUsers) ->
  'ngInject'
  vm = this

  # Get the user
  MnoeUsers.get($stateParams.userId).then(
    (response) ->
      vm.user = response
  )

  return
