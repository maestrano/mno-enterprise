@App.controller 'UserController', ($stateParams, $window, MnoeUsers) ->
  'ngInject'
  vm = this

  # Get the user
  MnoeUsers.get($stateParams.userId).then(
    (response) ->
      vm.user = response.data
  )

  vm.impersonateUser = () ->
    if vm.user
      url = '/mnoe/impersonate/user/' + vm.user.id
      $window.location.href = url

  return
