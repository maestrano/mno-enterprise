module = angular.module('maestrano.components.mno-flash-msg',[])

#============================================
# Component 'Flash Msg'
#============================================
module.controller('MnoFlashMsgCtrl',[
  '$scope', 'MsgBus',
  ($scope, MsgBus) ->
    
    # Message bus connection
    $scope.errors = MsgBus.subscribe('errors')
    
    # Only show the flash message if
    # there are errors in the pipe
    $scope.isFlashShown = () ->
      $scope.errors().length > 0
    
    # Empty the errors array in the MsgBus
    $scope.closeFlash = () ->
      MsgBus.publish('errors',[])
    
])

module.directive('mnoFlashMsg', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A'
      scope: {}
      controller: 'MnoFlashMsgCtrl'
      template: '
      <div class="alert alert-error alert-top fade" ng-class="isFlashShown() && \'in\'">
        <button class="close" ng-click="closeFlash()">&times;</button>
        <strong>Snap! This action couldn\'t be performed.</strong>
        <ul>
          <li ng-repeat="error in errors()">
            {{error}}
          </li>
        </ul>
      </div>'
    }
])