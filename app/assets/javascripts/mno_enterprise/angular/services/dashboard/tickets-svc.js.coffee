angular.module('maestrano.services.dashboard.tickets-svc', []).factory('DhbTicketsSvc', ['$http','$q','$window', ($http,$q,$window) ->
  # Configuration
  service = {}
  service.routes = {
    basePath: -> "/mnoe/jpi/v1/dashboard/user"
    loadPath: -> "#{service.routes.basePath()}/tickets"
    createPath: -> "#{service.routes.basePath()}/tickets"
    updatePath: (ticket) -> "#{service.routes.basePath()}/tickets/#{ticket.id}"
  }

  service.defaultConfig = {
    delay: 2000 * 60 # seconds - long polling delay
  }

  service.config = {
    bootstraped: false, # Hasn't been loaded at least once
    timerId: null, # The current timer id (used for long polling)
    $q: null # The current service promise
  }

  service.data = {}

  #======================================
  # Data Management
  #======================================
  # Return true if the service has been loaded at leaste once
  service.isBootstraped = ->
    service.config.bootstraped

  # Configure the service
  service.configure = (opts) ->
    angular.copy(opts,service.config)
    angular.extend(service.config,service.defaultConfig)

  # Load the tickets details
  service.load = (force = false) ->
    self = service
    if !self.config.$q? || force
      self.config.$q = $http.get(self.routes.loadPath()).then (success) ->
        angular.copy(success.data,self.data)

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
    self.stopAutoRefresh()
    self.load(true).then(self.startAutoRefresh)

  # Setup the service
  # A full reload is only performed if the user id
  # passed in the configOpts is different from the one
  # currently used
  # To force a service reload, use the 'reload' function
  service.setup = (configOpts = service.config)->
    self = service
    self.stopAutoRefresh()
    self.configure(configOpts)
    self.load(true).then(self.startAutoRefresh)

  service.createTicket = (opts) ->
    self = service
    data = opts
    q = $http.post(self.routes.createPath(),data).then (success)->
      ticket = success.data
      self.data["ticket#{ticket.id}"] = ticket
    return q

  service.postComment = (ticket,model) ->
    self = service
    opts = { transformRequest: angular.identity, headers: {'Content-Type': undefined} }
    data = new FormData()
    data.append('comment',model.comment)
    if model.attachment
      data.append('attachment',model.attachment)
    q = $http.put(self.routes.updatePath(ticket),data,opts).then (success) ->
      self.data["ticket#{ticket.id}"].comments.push(success.data)
    return q


  #======================================
  # Organization Management
  #======================================
  #service.organization = {}

  # Edit the details on a given organization
  # opts = { name: "SomeName", soa_enabled: true }
  #service.organization.update = (opts) ->
    #self = service
    #data = { organization: opts }
    #q = $http.put(self.routes.updatePath(),data).then (success)->
      #angular.copy(success.data.organization,self.data.organization)

    #return q

  return service
])
