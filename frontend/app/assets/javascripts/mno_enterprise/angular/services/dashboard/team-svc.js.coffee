angular.module('maestrano.services.dashboard.team-svc', []).factory('DhbTeamSvc', ['$http','$q','$window', ($http,$q,$window) ->
  # Configuration
  service = {}
  service.routes = {
    basePath: -> "/mnoe/jpi/v1/organizations/#{service.config.id}/teams"
    loadPath: -> "#{service.routes.basePath()}"
    createPath: -> "#{service.routes.basePath()}"
    showPath: (id) -> "/mnoe/jpi/v1/teams/#{id}"
    updatePath: (id) -> service.routes.showPath(id)
    addMembersPath: (id) -> "#{service.routes.showPath(id)}/add_users"
    removeMembersPath: (id) -> "#{service.routes.showPath(id)}/remove_users"
    destroyPath: (id) -> service.routes.showPath(id)
  }

  service.defaultConfig = {
    delay: 1000 * 60 * 2 # minutes - long polling delay
  }

  service.config = {
    id: null, # The organization id to load
    timerId: null, # The current timer id (used for long polling)
    $q: null # The current service promise
  }

  service.data = []

  #======================================
  # Data Management
  #======================================
  # Return the id of the currently loaded/loading organization
  service.getId = ->
    service.config.id

  # Configure the service
  service.configure = (opts) ->
    angular.copy(opts,service.config)
    angular.extend(service.config,service.defaultConfig)

  # Load the organization details
  # Document structure
  # :team(s)
  #   :id
  #   :name
  #   :users(array)
  #     [:id, :name, :surname]
  #   :app_instances(array)
  #     [:id, :name, :logo]
  #
  service.load = (force = false) ->
    self = service
    if !self.config.$q? || force
      self.config.$q = $http.get(self.routes.loadPath()).then (success) ->
        angular.copy(success.data.teams,self.data)

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


  #======================================
  # Team Management
  #======================================
  service.team = {}
  
  # Create a new team
  # opts = { name: "SomeName" }
  service.team.create = (opts) ->
    self = service
    data = { team: opts }
    q = $http.post(self.routes.createPath(),data).then (success)->
      self.data.push(success.data.team)
      success.data.team
    
    return q
  
  # Edit the details on a given organization
  # opts = { name: "SomeName", app_instances: [{id: 3}] }
  service.team.update = (teamId,opts) ->
    self = service
    data = { team: opts }
    q = $http.put(self.routes.updatePath(teamId),data).then (success)->
      team = _.find(self.data, (t) -> t.id == teamId)
      angular.copy(success.data.team,team)

    return q
  
  # Destroy a team
  service.team.destroy = (teamId) ->
    self = service
    q = $http.delete(self.routes.destroyPath(teamId)).then (success)->
      team = _.find(self.data, (t) -> t.id == teamId)
      idx = self.data.indexOf(team)
      self.data.splice(idx,1)
      team
  
  #======================================
  # Member Management
  #======================================
  service.members = {}
  # Accept an array of user objects
  # [{ id: 1 }]
  # Or
  # an array of user id
  # Or
  # (not yet implemented) a single email address
  # Or
  # (not yet implemented) a an array of email addresses
  # Or
  # (not yet implemented) a newline separated list of email addresses
  service.members.add = (teamId, members) ->
    self = service
    baseList = members

    finalList = []
    _.each baseList, (e) ->
      if angular.isObject(e)
        finalList.push(e)
      else
        finalList.push({id: e})

    data = { team: { users: finalList } }
    q = $http.put(self.routes.addMembersPath(teamId), data).then (success)->
      team = _.find(self.data, (t) -> t.id == teamId)
      angular.copy(success.data.team.users,team.users)

    return q

  # Remove a member from an organization
  # Accept an array of user objects
  # [{ id: 1 }]
  # Or
  # an array of user id
  service.members.remove = (teamId, members) ->
    self = service
    baseList = members

    finalList = []
    _.each baseList, (e) ->
      if angular.isObject(e)
        finalList.push(e)
      else
        finalList.push({id: e})

    data = { team: { users: finalList } }
    q = $http.put(self.routes.removeMembersPath(teamId),data).then (success)->
      team = _.find(self.data, (t) -> t.id == teamId)
      angular.copy(success.data.team.users,team.users)

    return q

  return service
])
