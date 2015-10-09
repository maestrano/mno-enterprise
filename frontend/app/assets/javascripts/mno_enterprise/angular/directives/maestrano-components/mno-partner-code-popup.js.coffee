module = angular.module('maestrano.components.mno-partner-code-popup',['maestrano.assets'])

#============================================
# Component 'Select App'
#============================================
module.controller('MnoPartnerCodePopupCtrl',[
  '$scope', '$rootScope', '$window', 'Utilities', '$modal','DashboardUser','CurrentUserSvc',
  ($scope, $rootScope, $window, Utilities, $modal, DashboardUser, CurrentUserSvc) ->
    $scope.assetPath = $rootScope.assetPath

    #===================================
    # Load Scope
    #===================================
    $scope.partnerCodeModal = partnerCodeModal= {}


    #===================================
    # partnerCodeModal
    #===================================
    # Open the partnerCodeModal and reset the proceed action
    partnerCodeModal.open = () ->
      self = partnerCodeModal
      self.$instance = $modal.open(templateUrl: 'internal-partner-code-popup.html', scope: $scope)
      self.isSaveInProgress = false
      self.model = {}
      self.errors = null
      self.$instance.result.finally ->
        self.$instance = null

    partnerCodeModal.proceedEnabled = () ->
      self = partnerCodeModal
      return self.model.resellerCode && !self.model.resellerCode.match(/\s+/)

    # Close the transferModal and reset its values
    partnerCodeModal.close = () ->
      self = partnerCodeModal
      self.$instance.close()
      self.$instance = null


    partnerCodeModal.proceed = () ->
      self = partnerCodeModal
      self.isSaveInProgress = true
      # TODO: we should create a custom action for that that would check
      # if the reseller exists before updating the reseller code
      DashboardUser.update({reseller_code:self.model.resellerCode}).then(
        (success) ->
          self.isSaveInProgress = false
          self.close()
        ,(error) ->
          self.errors = Utilities.processRailsError(error)
          self.isSaveInProgress = false
      )


    #===================================
    # Init Code
    #===================================
    # Listener for the modal opening
    CurrentUserSvc.loadDocument().then (data) ->
      resellerCode = CurrentUserSvc.document.current_user.reseller_code
      if (!resellerCode || resellerCode == '')
        partnerCodeModal.open()
])

module.directive('mnoPartnerCodePopup', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/partner_code_popup.html'],
      controller: 'MnoPartnerCodePopupCtrl'
    }
])
