module = angular.module('maestrano.components.mno-notification-widget',['maestrano.assets'])

#============================================
# Component 'Notification Widget'
#============================================
# Messages sent to the notificationQueue will be
# displayed on screen
# ---
# A message can be a string or a js object
# If string (can be html) then it will be displayed as 'info'
# If object then the expect format is:
# {
#   type: 'success'/'info'/'warning'/'danger' (default: 'info')
#   msg: a string object (can be html)
#   timeout: a number of milliseconds after which the msg will
#            be discarded (default: 10 minutes). Use -1 for never.
#   popup: false/(true | object), display a popup in addition (default: false)
#         If object then the structure should be:
#         {
#           title: Popup title (default: '')
#           content: Popup content (default to msg attribute above)
#           dismissText: Dismiss button text
#         }
# }
#
module.controller('MnoNotificationWidgetCtrl',[
  '$scope', '$rootScope', 'Utilities', 'MsgBus', '$timeout', '$window','$modal', '$sce',
  ($scope, $rootScope, Utilities, MsgBus, $timeout, $window, $modal, $sce) ->
    $scope.assetPath = $rootScope.assetPath
    $scope.windowHeight = $window.innerHeight

    #===================================
    # Load Scope
    #===================================
    $scope.notifWidget = notifWidget = {}
    $scope.notifPopup = notifPopup = {}

    # These are the messages received via the bus
    # Note the return value is a *function*
    notifWidget.inboundQueue = MsgBus.subscribe('notificationQueue')

    # These are the messages currently displayed
    notifWidget.outboundQueue = []

    # These are messages in the popupQueue
    notifWidget.popupQueue = []

    #===================================
    # notifWidget methods
    #===================================
    notifWidget.jqAlertElem = (msgIndex) ->
      $(".notification-widget #notification#{msgIndex}")

    notifWidget.classFor = (messageObject) ->
      return "alert alert-#{messageObject.type}"

    notifWidget.pushMsg = (messageObject) ->
      self = this
      if angular.isObject(messageObject) || (angular.isString(messageObject) && messageObject != '')
        if angular.isObject(messageObject)
          if messageObject.msg && messageObject.msg != ''
            realMsgObj = {
              type: (messageObject.type || 'info'),
              msg: $sce.trustAsHtml(messageObject.msg),
              timeout: (messageObject.timeout || 10*60*1000),
              popup: (messageObject.popup || false)
            }
        else if angular.isString(messageObject)
          realMsgObj = {
            type: 'info',
            msg: $sce.trustAsHtml(messageObject),
            timeout: 10*60*1000,
            popup: false
          }

        # Push message
        if realMsgObj
          # Push to outbound queue
          msgIndex = self.outboundQueue.push(realMsgObj) - 1

          # Push to popupQueue if popup requested
          if realMsgObj.popup
            self.popupQueue.push(realMsgObj)

          # Animate
          # Need to wait for ng-repeat to take the new element
          # into account
          $timeout(
            () ->
              self.jqAlertElem(msgIndex).animate({'right': '0px'},500)
            ,400
          )

          # Configure auto discard
          if angular.isNumber(realMsgObj.timeout) && realMsgObj.timeout > 0
            $timeout(
              () ->
                self.closeMsg(realMsgObj)
              ,realMsgObj.timeout
            )


    notifWidget.closeMsg = (messageObject) ->
      self = this
      msgIndex = self.outboundQueue.indexOf(messageObject)
      if msgIndex >= 0
        self.jqAlertElem(msgIndex).animate(
          { 'right': '-300px'}
          , 500
          ,() ->
            self.outboundQueue.splice(msgIndex,1)
            $scope.$apply()
        )
      return true

    #===================================
    # notifPopup methods
    #===================================
    notifPopup.open = () ->
      self = this
      self.$instance = $modal.open(templateUrl: 'internal-notif-popup-modal.html', scope: $scope)
      self.isOpen = true
      self.msgObject = notifWidget.popupQueue[0]
      self.model = {}

      # Build model
      if angular.isObject(self.msgObject.popup)
        self.model.title = (self.msgObject.popup.title || 'Notification')
        self.model.content = (self.msgObject.popup.content || self.msgObject.msg)
        self.model.dismissText = (self.msgObject.popup.dismissText || 'Dismiss')
      else
        self.model.title = 'Notification'
        self.model.content = self.msgObject.msg
        self.model.dismissText = 'Dismiss'

    notifPopup.close = () ->
      self = this
      self.$instance.close()
      self.isOpen = false
      self.msgObject = undefined
      self.model = {}
      notifWidget.popupQueue.shift()

    #===================================
    # Pop items from the inboundQueue
    # and push them to the outbound one
    # ---
    # Wait 1.5 seconds before displaying
    # messages so that page gets properly
    # loaded
    #===================================
    # Process the initial messages
    if angular.isArray($scope.mnoNotificationWidget()) && $scope.mnoNotificationWidget().length > 0
     _.each($scope.mnoNotificationWidget(),
       (msgObject) ->
         notifWidget.pushMsg(msgObject)
     )

    $timeout(() ->
        # Watch the inboundQueue
        $scope.$watch(
          () ->
             if notifWidget.inboundQueue().length > 0
                notifWidget.pushMsg(notifWidget.inboundQueue().shift())
          ,(->)
        )
        
      ,1500
    )

    #===================================
    # Watch the popupQueue and open modals
    # successively until empty
    #===================================
    $scope.$watch(
      () ->
        if !notifPopup.isOpen && notifWidget.popupQueue.length > 0
          notifPopup.open()
      ,(->))
])

module.directive('mnoNotificationWidget', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        mnoNotificationWidget: '&',
        userLoggedIn: '&'
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/notification-widget.html'],
      controller: 'MnoNotificationWidgetCtrl',
    }
])
