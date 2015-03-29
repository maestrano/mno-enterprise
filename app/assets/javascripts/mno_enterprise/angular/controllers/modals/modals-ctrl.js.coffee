module = angular.module('maestrano.controllers.modals-ctrl',['maestrano.assets'])

# -------------------------------------------------------------------------
# This module is meant to contain the small controllers for simple modals
# For more complex modals, put the controller in its own file
# -------------------------------------------------------------------------

#============================================
# NewOrgModalCtrl
#============================================
module.controller('NewOrgModalCtrl',[
  '$scope','$modalInstance','Utilities','DhbOrganizationSvc','$modalInstanceCB'
  ($scope, $modalInstance, Utilities, DhbOrganizationSvc, $modalInstanceCB) ->

    $scope.modal = { model:{} }

    $scope.modal.close = ->
      $modalInstance.close()

    $scope.modal.proceed =  ->
      self = $scope
      modal = self.modal
      modal.isLoading = true
      data = { organization: modal.model }
      DhbOrganizationSvc.organization.create(data).then(
        (success) ->
          modal.errors = ''
          modal.close()
          # Callback method
          if $modalInstanceCB then $modalInstanceCB(success.data)
        ,(errors) ->
          modal.errors = Utilities.processRailsError(errors)
      ).finally(-> modal.isLoading = false)

])

#============================================
# NewOrgResellerReqModalCtrl
#============================================
module.controller('NewOrgResellerReqModalCtrl',[
  '$scope','$modalInstance','Utilities','DhbOrganizationSvc','$modalInstanceCB'
  ($scope, $modalInstance, Utilities, DhbOrganizationSvc, $modalInstanceCB) ->

    $scope.modal = { model:{} }

    $scope.modal.close = ->
      $modalInstance.close()

    $scope.modal.proceed =  ->
      self = $scope
      modal = self.modal
      modal.isLoading = true
      data = { organization: modal.model, reseller_req:true }
      DhbOrganizationSvc.organization.create(data).then(
        (success) ->
          modal.errors = ''
          modal.close()
        ,(errors) ->
          modal.errors = Utilities.processRailsError(errors)
      ).finally(-> modal.isLoading = false)

])
