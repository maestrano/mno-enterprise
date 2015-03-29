module = angular.module('maestrano.components.mno-partner-contact',['maestrano.assets'])

#============================================
# Component 'partner contact'
#============================================
module.controller('MnoPartnerContactCtrl',[
  '$scope', '$rootScope', '$http','$modal',
  ($scope, $rootScope, $http, $modal) ->
    $scope.assetPath = $rootScope.assetPath

    $scope.templateParameter = {}
    $scope.templateParameter.modalOpen = false
    $scope.templateParameter.feedbackMessage = ""
    $scope.templateParameter.errorMessage = ""

    $scope.openCloseModal = ->
      if $scope.templateParameter.modalOpen
        $scope.templateParameterInstance.close()
        $scope.templateParameter.modalOpen = false
      else
        $scope.templateParameterInstance = $modal.open(templateUrl: 'internal-template-param-modal.html', scope: $scope)
        $scope.templateParameter.modalOpen = true

    $scope.form = {}

    $scope.sendRequest = ->
      $scope.form.partner_id = $scope.partnerId
      $scope.form.inProgress = true
      $http.post('/mnoe/jpi/v1/partners/contact', { form: $scope.form }).then(
        (success) ->
          $scope.form.inProgress = false
          $scope.form.first_name = ""
          $scope.form.last_name = ""
          $scope.form.email = ""
          $scope.form.message = ""
          $scope.templateParameter.feedbackMessage = "Your message has been successfully sent"
        ,(errors) ->
          $scope.templateParameter.errorMessage = "Your message couldn't be sent. Please try again later."

      )


    $scope.openCloseModalFun = $scope.openCloseModal

])

module.directive('mnoPartnerContact', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        openCloseModalFun: '=',
        partnerName: '@',
        partnerId: '@',
      },
      templateUrl: TemplatePath['maestrano-components/partner_contact.html'],
      controller: 'MnoPartnerContactCtrl',
  }
])

