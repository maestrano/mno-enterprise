module = angular.module('maestrano.components.mno-autostop-app',['maestrano.assets'])

#============================================
# Component 'Select App'
#============================================
module.controller('MnoAutostopAppCtrl',[
  '$scope', '$rootScope', '$window', 'MsgBus', 'Utilities','$modal', '$http'
  ($scope, $rootScope, $window, MsgBus, Utilities, $modal, $http) ->
    $scope.assetPath = $rootScope.assetPath
    $scope.windowHeight = $window.innerHeight

    #===================================
    # Load Scope
    #===================================
    $scope.autostopModal = autostopModal = {}
    $scope.currentAppBeingAsked = undefined


    if angular.isArray($scope.mnoAutostopApp())
      $scope.appQueue = appQueue = $scope.mnoAutostopApp
    else if angular.isObject($scope.mnoAutostopApp())
      $scope.appQueue = appQueue = (->[$scope.mnoAutostopApp()])
    else
      $scope.appQueue = appQueue = MsgBus.subscribe('autostopQueue')

    #===================================
    # Watch the queue and open modals
    # successively until empty
    #===================================
    $scope.$watch(
      () ->
        if !autostopModal.isOpen
          if $scope.currentAppBeingAsked != undefined
            autostopModal.open($scope.currentAppBeingAsked)
          else if appQueue().length > 0
            $scope.currentAppBeingAsked = appQueue()[0]
      ,(->))


    #===================================
    # AutostopModal
    #===================================
    # Open the autostopModal and reset the proceed action
    autostopModal.open = (instance) ->
      self = autostopModal
      self.$instance = $modal.open(templateUrl: 'internal-autostop-modal.html', scope: $scope)
      self.isOpen = true
      self.instance = instance
      self.defaultDuration = 1
      self.model = {}
      self.model.duration = self.defaultDuration
      if instance.name
        self.title = "Choose idle time for #{instance.name}"
      else if instance.appName
        self.title = "Choose idle time for #{instance.appName}"
      else
        self.title = "Choose idle time for this app"

      self.proceed =  () ->
        self.inProgress = true

        if self.model.duration != self.defaultDuration
          $http.put("/app_instances/#{instance.id}/autostop", {duration: self.model.duration}).then(
            (success) ->
              self.close()
            (error) ->
              self.errors = Utilities.processRailsError(error)
              self.inProgress = false
          )
        else
          self.close()

    autostopModal.availableDurations = () ->
      self = autostopModal
      return [1,2,3,4,5,6,8,10]


    autostopModal.select = (duration) ->
      self = autostopModal
      self.model.duration = duration


    autostopModal.classFor = (duration) ->
      self = autostopModal
      if duration == self.model.duration
        return "selected"

    autostopModal.proceedEnabled = () ->
      return true

    autostopModal.text = () ->
      self = autostopModal
      return "Your app will automatically be offlined after <b class=\"text-info\">#{self.model.duration} hour(s)</b> of inactivity."

    # Close the transferModal and reset its values
    autostopModal.close = () ->
      self = autostopModal
      self.$instance.close()
      self.errors = []
      $scope.currentAppBeingAsked = undefined
      self.inProgress = false
      self.model = {}
      self.instance = {}
      self.cancel = self.defaultProceed
      self.isOpen = false
      appQueue().shift()


    # This is the default proceed method
    autostopModal.defaultProceed = () ->
      autostopModal.close()
])

module.directive('mnoAutostopApp', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        mnoAutostopApp: '&'
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/autostop_app.html'],
      controller: 'MnoAutostopAppCtrl'
    }
])
