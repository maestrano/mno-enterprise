angular.module('maestrano.services.dashboard.apps-document', []).factory('DashboardAppsDocument', ['$http','$q','$window', ($http, $q, $window) ->
  # Configuration
  service = {}
  service.routes = {
    basePath: -> "/mnoe/jpi/v1/organizations/#{service.config.id}/app_instances"
    plan: {
      changePath: (id) -> "/organizations/#{id}/app_change_requests"
    }
  }

  service.defaultConfig = {
    delay: 1000 * 60 # seconds - long polling delay
    timestamp: 0
  }

  service.config = {
    id: null, # The organization id to load
    timerId: null, # The current timer id (used for long polling)
    $q: null # The current service promise
  }

  service.data = {}

  #======================================
  # Data Management
  #======================================
  # Return the id of the currently loaded/loading organization
  service.getId = ->
    service.config.id

  # Configure the service
  service.configure = (opts) ->
    # If we change the orga id than we reinitialize the data object
    if opts.id then service.data = {}
    angular.copy(opts,service.config)
    angular.extend(service.config,service.defaultConfig)

  # Load the apps details
  service.load = (force = false) ->
    self = service
    if !self.config.$q? || force
      self.config.$q = $http.get("#{self.routes.basePath()}?timestamp=#{self.config.timestamp}").then (success) ->
        angular.extend(self.data,success.data.app_instances)
        self.config.timestamp = success.data.timestamp

    return self.config.$q

  # Start data auto refresh for the service
  service.startAutoRefresh = ->
    self = service
    unless self.config.timerId?
      self.config.timerId = $window.setInterval((-> self.load(true)),self.config.delay)

  # Stop data auto refresh for the service
  service.stopAutoRefresh = ->
    self = service
    if self.config.timerId?
      $window.clearInterval(self.config.timerId)
      self.config.timerId = null

  # Force the service to reload
  service.reload = ->
    self = service
    self.stopAutoRefresh()
    self.config.timestamp = 0
    angular.copy({},self.data)
    self.load(true).then(self.startAutoRefresh)

  # Setup the service
  # A full reload is only performed if the orga id
  # passed in the configOpts is different from the one
  # currently used
  # To force a service reload, use the 'reload' function
  service.setup = (configOpts = service.config)->
    self = service
    if configOpts.id != self.config.id
      self.stopAutoRefresh()
      self.configure(configOpts)
      self.load(true).then(self.startAutoRefresh)

  return service

])
