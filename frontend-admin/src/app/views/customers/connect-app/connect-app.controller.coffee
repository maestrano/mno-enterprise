@App.controller 'ConnectAppController', ($stateParams, $window, $uibModal, MnoeOrganizations, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.mnoAppInstances = MnoAppsInstances

  vm.orgId = $stateParams.orgId

  vm.isLoading = true
  MnoeOrganizations.get($stateParams.orgId).then(
    (response) ->
      vm.organization = response.data
  ).finally(-> vm.isLoading = false)

  #====================================
  # App Connect modal
  #====================================
  vm.connectAppInstance = (app) ->
    switch app.nid
      when "xero" then modalInfo = {
        template: "app/views/customers/app-connect-modal/app-connect-modal-xero.html",
        controller: 'ConnectXeroModalCtrl'
      }
      when "myob" then modalInfo = {
        template: "app/views/customers/app-connect-modal/app-connect-modal-myob.html",
        controller: 'ConnectMyobModalCtrl'
      }
      else
        $window.location.href = MnoAppsInstances.oAuthConnectPath(app)
        return

    $uibModal.open(
      templateUrl: modalInfo.template
      controller: modalInfo.controller
      controllerAs: 'vm'
      resolve:
        app: -> app
    )

  return
