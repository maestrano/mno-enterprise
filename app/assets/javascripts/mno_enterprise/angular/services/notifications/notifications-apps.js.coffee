# This service is used to monitor the Apps activities and notify the user
#
angular.module('maestrano.notifications.apps', []).factory('notificationsForApps', [
  '$rootScope', 'MsgBus', '$timeout','$http','$window',
  ($rootScope, MsgBus, $timeout, $http, $window) ->
    # Configure the cookie options
    $.cookie.json = true
    $.cookie.defaults.path = '/'

    # Init
    notifManager = {}
    notifManager.appInstances = {}
    notifManager.appContext = {}
    notifManager.notifQueue = MsgBus.subscribe('notificationQueue') # return value is function
    notifManager.transitionStatuses = ['starting','restarting','stopping', 'terminating', 'staged', 'provisioning']

    # Routing
    notifManager.routes = {
      basePath: -> "/mnoe/jpi/v1/dashboard/user/app_instances"
    }

    # Configuration
    notifManager.defaultConfig = {
      delay: 60 * 1000 # seconds - long polling delay
      timestamp: 0
    }

    notifManager.config = {
      timerId: null, # The current timer id (used for long polling)
      $q: null # The current service promise
    }

    notifManager.data = {}

    # Configure the service
    notifManager.configure = (opts) ->
      #angular.copy(opts,notifManager.config)
      angular.extend(notifManager.config,notifManager.defaultConfig)

    # Cookie config
    notifManager.parentCookieName = 'user_notifications'
    notifManager.name = 'notifications_for_apps'
    notifManager.cookieExpiration = 10 #in minutes

    # Getter/Setter for the notifications cookie
    # If a value is specified then the key gets written
    # Otherwise just read the key
    notifManager.cookie = (key, value) ->
      self = this
      # Get the right tutorial cookie
      # Either a top level cookie or a sub cookie
      if self.parentCookieName
        cookieName = self.parentCookieName
        cookie = $.cookie(cookieName)
        cookie ?= {}
        cookie[self.name] ?= {}
        cookieStore = cookie[self.name]
      else
        cookieName = self.name
        cookie = $.cookie(cookieName)
        cookie ?= {}
        cookieStore = cookie

      # Write the value and save the cookie
      if value?
        cookieStore[key] = value
        $.cookie(cookieName, cookie, {
          expires: new Date((new Date).getTime() + self.cookieExpiration*60*1000),
        })

      # Read
      return cookieStore[key] ? null

    # Enable the notification manager
    notifManager.enable = () ->
      self = this
      self.setup()

    # Get the list of AppInstances
    notifManager.load = (force = false) ->
      self = notifManager
      if !self.config.$q? || force
        self.config.$q = $http.get("#{self.routes.basePath()}?timestamp=#{self.config.timestamp}").then (success) ->
          data = {}
          unless _.isEmpty success.data.app_instances
            angular.extend(self.data,success.data.app_instances)
            self.checkForNotifications()
          self.config.timestamp = success.data.timestamp
      return self.config.$q

    # Start data auto refresh for the service
    notifManager.startAutoRefresh = ->
      self = notifManager
      unless self.config.timerId?
        self.config.timerId = $window.setInterval((-> self.load(true)),self.config.delay)

    # Stop data auto refresh for the service
    notifManager.stopAutoRefresh = ->
      self = notifManager
      if self.config.timerId?
        $window.clearInterval(self.config.timerId)
        self.config.timerId = null

    # Force the service to reload
    notifManager.reload = ->
      self = notifManager
      self.stopAutoRefresh()
      self.load(true).then(self.startAutoRefresh)

    # Setup the service
    # To force a service reload, use the 'reload' function
    notifManager.setup = (configOpts = notifManager.config)->
      self = notifManager
      self.stopAutoRefresh()
      self.configure(configOpts)
      self.load(true).then(self.startAutoRefresh)


    # Compare the current status of AppInstances with the
    # previous one. Create notitifications based on that
    notifManager.checkForNotifications = () ->
      self = notifManager
      # Check for updates
      _.each self.data, (appInstance) ->
        if appInstance.status == 'running' || appInstance.status == 'stopped' || appInstance.status == 'terminated'
          if self.appContext[appInstance.id] && appInstance.status != self.appContext[appInstance.id]
            self.addNotificationFor(appInstance)
        self.appContext[appInstance.id] = appInstance.status

      # Store context in cookie in 3 seconds (so if user changes
      # page at the same time a notification is displayed the notification
      # gets redisplayed on the next page)
      $timeout((-> self.cookie('context',self.appContext)), 3*1000)

    # Load the status of each app in object store
    notifManager.loadContext = () ->
      self = notifManager
      if context = self.cookie('context')
        self.appContext = context
      else
        _.each self.data, (appInstance) ->
          if _.contains(self.transitionStatuses, appInstance.status)
            self.appContext[appInstance.id] = appInstance.status
        self.cookie('context',self.appContext)

    # Push a notification
    notifManager.addNotificationFor = (appInstance) ->
      self = this
      msgObject = {}
      msgObject.type = {running:'success',stopped:'warning',terminated:'danger'}[appInstance.status]
      msgObject.type ||= 'info'
      msgObject.msg = "#{appInstance.name} is now #{appInstance.status}"

      # Customize message for 'running'
      if appInstance.status == 'running'
        # Initialize popup object
        msgObject.popup = {}
        msgObject.popup.title = "#{appInstance.name} is ready to be used"

        # Open in new tab
        msgObject.msg += " - <a href='#{appInstance.http_url}' target='_blank'>Click to Open</a>"
        msgObject.popup.content = "<div class='align-center'><p>#{appInstance.name} is now online. Click the button below to open your application.</p>"
        msgObject.popup.content += "<br><a href='#{appInstance.http_url}' target='_blank' class='fbtn fbtn-success fbtn-large'>Open #{appInstance.name}</a></div>"

        # Added credentials
        if appInstance.first_credentials && appInstance.first_credentials.login && !appInstance.sso_enabled
          credentialsText = ''
          credentialsText += "<em>If this is the first time you login to this app then use:</em>"
          credentialsText += "<br><b>Login</b>: #{appInstance.first_credentials.login}"
          if appInstance.first_credentials.password
            credentialsText += "<br><b>Password</b>: #{appInstance.first_credentials.password}"
          else
            credentialsText += "<br><b>Password</b>: <em>Leave blank</em>"
          msgObject.msg += "<br><br>#{credentialsText}"
          msgObject.popup.content += "<br><br><div class='alert alert-info'>#{credentialsText}</div>"

      self.notifQueue().push(msgObject)

    return notifManager
])
