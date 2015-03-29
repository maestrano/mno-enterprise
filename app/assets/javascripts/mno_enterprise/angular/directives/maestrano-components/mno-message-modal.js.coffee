module = angular.module('maestrano.components.mno-message-modal',['maestrano.assets'])

#============================================
#
#============================================
module.controller('MnoMessageModalCtrl',[
  '$scope','$modal','MessageSvc','$location','TemplatePath','AssetPath',
  ($scope, $modal, MessageSvc, $location, TemplatePath, AssetPath) ->
    $scope.assetPath = AssetPath

    $scope.modal = {}
    message = null

    $scope.modal.title = ->
      return message.title || "Congratulations!"

    $scope.modal.body = ->
      return message.body

    $scope.templateUrl = ->
      return message.templateUrl

    $scope.modal.open = ->
      $scope.modal.$instance = $modal.open(templateUrl:'internal-message-modal.html',scope:$scope, size:'lg')
      $scope.modal.$instance.result.finally ->
        $scope.modal.$instance = null
        MessageSvc.next()


    $scope.modal.close = ->
      $scope.modal.$instance.close()

    $scope.modal.goBackToDashboard = ->
      $scope.modal.close()
      $location.path("/")


    $scope.$watch(( -> MessageSvc.count),
      () ->
        if MessageSvc.count > 0
          message = MessageSvc.pullMessage()
          $scope.modal.open()
    )


])

module.directive('mnoMessageModal', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/default_template.html'],
      controller: 'MnoMessageModalCtrl'
    }
])
