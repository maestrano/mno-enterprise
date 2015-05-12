angular.module('maestrano.services.impac.dashboarding-svc', []).factory('ImpacDashboardingSvc', [
  '$http','$q','$window','MessageSvc','CurrentUserSvc', '$timeout', 'Miscellaneous',
  ($http,$q,$window,MessageSvc,CurrentUserSvc, $timeout, Miscellaneous) ->
    # Configuration
    service = {}
    service.routes = {
      # Maestrano dashboarding API
      provider: "/mnoe/jpi/v1/impac"

      # Dashboard routes
      basePath: -> "#{service.routes.provider}/dashboards"
      showPath: (id) -> "#{service.routes.basePath()}/#{id}"
      createPath: -> service.routes.basePath()
      updatePath: (id) -> service.routes.showPath(id)
      deletePath: (id) -> service.routes.showPath(id)

      baseWidgetPath: (id) -> "#{service.routes.provider}/widgets/#{id}"
      # Impac! js_api
      showWidgetPath: Miscellaneous.impacUrls.get_widget,
      createWidgetPath: (dashboardId) -> "#{service.routes.showPath(dashboardId)}/widgets"
      updateWidgetPath: (id) -> service.routes.baseWidgetPath(id)
      deleteWidgetPath: (id) -> service.routes.baseWidgetPath(id)
      
    }

    service.defaultConfig = {
      delay: 1000 * 60 * 10 # minutes - long polling delay
    }

    service.config = {
      id: null # current dashboard loaded
      organizationId: null, # The organization id to load
      timerId: null, # The current timer id (used for long polling)
      $q: null # The current service promise
    }

    service.data = []

    service.isLocked = false

    #======================================
    # Data Management
    #======================================
    # Return the id of the currently displayed dashboard 
    service.getId = ->
      if (!service.config.id && service.data.length > 0)
        service.config.id = service.data[0].id
      else
        service.config.id

    service.getDashboards = ->
      service.data
    
    # Return the id of the currently loaded/loading organization
    service.getOrganizationId = ->
      service.config.organizationId

    # Configure the service
    service.configure = (opts) ->
      angular.copy(opts,service.config)
      angular.extend(service.config,service.defaultConfig)

    service.load = (force = false) ->
      self = service
      if !self.config.$q? || force
        self.config.$q = $http.get(self.routes.basePath()).then (success) ->
          angular.copy(success.data,self.data)
      return self.config.$q
    
    #======================================
    # Analytics Dashboard Management
    #======================================
    service.dashboards = {}

    # Opts require
    # - name: the dashboard name
    # - organization_id: the organization id
    service.dashboards.create = (opts) ->
      self = service
      data = { dashboard: opts }
      data['dashboard']['organization_id'] ||= self.config.organizationId
      
      $http.post(self.routes.createPath(),data).then(
        (success) ->
          dashboard = success.data
          self.data.push(dashboard)
          self.config.id = dashboard.id
          return dashboard
      )
    
    # Delete a dashboard
    service.dashboards.delete = (id) ->
      self = service
      $http.delete(self.routes.deletePath(id)).then(
        (success) ->
          self.config.id = null
          dhbs = self.data
          self.data = _.reject(self.data, (e) -> e.id == id)
      )
    
    # Update a dashboard
    service.dashboards.update = (id, opts, overrideCurrentDhb=yes) ->
      self = service
      data = { dashboard: opts }
      $http.put(self.routes.updatePath(id),data).then(
        (success) ->
          dhb = _.findWhere(self.data,{id: id})
          angular.extend(dhb,success.data) if overrideCurrentDhb
        , (->)
      )

    #======================================
    # Widgets Management
    #======================================
    service.widgets = {}
    
    # Create a new widget
    # Attributes
    # - widget_category category of widgets
    service.widgets.create = (dashboardId, opts) ->
      self = service
      data = { widget: opts }
      $http.post(self.routes.createWidgetPath(dashboardId), data).then(
        (success) ->
          widget = success.data
          dashboard = _.findWhere(self.data,{ id: dashboardId })
          dashboard.widgets.push(widget)
          return widget
      )
    
    service.widgets.show = (widget) ->
      self = service
      data = { owner: widget.owner, sso_session: CurrentUserSvc.getSsoSessionId(), metadata: widget.metadata, engine: widget.category }
      $http.post(self.routes.showWidgetPath, data).then(
        (success) ->
          return success.data
        (failure) ->
          return failure
      )
    
    # LOCKER / 1 WIDGET AT A TIME
    # service.widgets.show = (widget) ->
    #   self = service
    #   if !self.isLocked
    #     self.isLocked = true
    #     data = { owner: widget.owner, sso_session: CurrentUserSvc.getSsoSessionId(), metadata: widget.metadata, engine: widget.category }
    #     $http.post(self.routes.showWidgetPath, data).then(
    #       (success) ->
    #         self.isLocked = false
    #         return success.data
    #       (failure) ->
    #         self.isLocked = false
    #     )
    #   else
    #     $timeout( ->
    #       self.widgets.show(widget)
    #     ,300)

    # Delete a widget
    # TODO: currentDhbId should be stored in the service
    service.widgets.delete = (widgetId, currentDhb) ->
      self = service
      $http.delete(self.routes.deleteWidgetPath(widgetId)).then(
        (->)
          currentDhb.widgets = _.reject(currentDhb.widgets, (widget) -> widget.id == widgetId  )
      )

    service.widgets.update = (widget,opts) ->
      self = service
      data = { widget: opts }
      $http.put(self.routes.updateWidgetPath(widget.id),data)
    
    return service
])