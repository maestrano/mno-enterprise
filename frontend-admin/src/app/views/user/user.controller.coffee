@App.controller 'UserController', ($stateParams, $window, MnoeUsers, ADMIN_PANEL_CONFIG) ->
  'ngInject'
  vm = this

  vm.impersonation_enabled = if ADMIN_PANEL_CONFIG.impersonation then not ADMIN_PANEL_CONFIG.impersonation.disabled else true

  # Get the user
  MnoeUsers.get($stateParams.userId).then(
    (response) ->
      vm.user = response.data
  )

  vm.impersonateUser = () ->
    if vm.user
      redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
      url = "/mnoe/impersonate/user/#{vm.user.id}?redirect_path=#{redirect}"
      $window.location.href = url

  return
