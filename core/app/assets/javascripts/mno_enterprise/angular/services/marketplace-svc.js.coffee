angular.module('maestrano.services.marketplace-svc', []).factory('MarketplaceSvc', ['$http','$q', ($http,$q) ->
  # Configuration
  service = {}
  service.routes = {
    indexPath: -> "/mnoe/jpi/v1/marketplace"
    showPath: (id) -> "#{service.routes.indexPath()}/#{id}"
  }
  
  # No default config for the moment
  service.defaultConfig = {}
  
  service.config = { 
    $q: null # The current service promise
  }
  
  service.data = {}
  
  #======================================
  # Data Management
  #======================================
  # Configure the service
  service.configure = (opts) ->
    angular.copy(opts,service.config)
    angular.extend(service.config,service.defaultConfig)
  
  # Load the organization details
  # Document structure
  # :categories(all app categories)
  # :apps
  #   [{ 
  #     :id, :name, :stack, :key_benefits, 
  #     :is_responsive, :is_star_ready, :is_connec_ready, 
  #     :description, :testimonials, :pictures, :tutorial_page 
  #   }]
  #
  service.load = (force = false) ->
    self = service
    if !self.config.$q? || force
      self.config.$q = $http.get(self.routes.indexPath()).then (success) ->
        angular.copy(success.data,self.data)
    
    return self.config.$q
  
  # Force the service to reload
  service.reload = ->
    self.load(true).then(self.startAutoRefresh)
  
  # Setup the service
  # A load is only triggered if the service does not have
  # a promise already 
  # To force a service reload, use the 'reload' function
  service.setup = (configOpts = {})->
    self = service
    if !self.config.$q?
      self.configure(configOpts)
      self.load(true)
  
  return service
])