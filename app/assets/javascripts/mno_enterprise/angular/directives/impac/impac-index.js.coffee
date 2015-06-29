module = angular.module('maestrano.impac.index',['maestrano.assets'])

module.controller('ImpacIndexCtrl',[
  '$scope','$http','$q','$filter','$modal','$log', '$timeout', 'AssetPath','Utilities','Miscellaneous','DhbOrganizationSvc','ImpacDashboardingSvc','CurrentUserSvc','TemplatePath',
  ($scope, $http, $q, $filter, $modal, $log, $timeout, AssetPath, Utilities, Miscellaneous, DhbOrganizationSvc, ImpacDashboardingSvc, CurrentUserSvc, TemplatePath) ->

    #====================================
    # Initialization
    #====================================
    $scope.widgetsList = {}
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      if val?
        $q.all([DhbOrganizationSvc.load(),ImpacDashboardingSvc.load(),CurrentUserSvc.loadDocument()]).then ()->
          $scope.initialize()

    $scope.initialize = () ->
      $scope.user = CurrentUserSvc.document.current_user
      # $scope.widgetsList = Miscellaneous.analyticsWidgets
      $scope.currentWidget = {}
      $scope.currentDhbId = ImpacDashboardingSvc.getId()
      $scope.refreshDashboards()

      $scope.isLoading = false

    # When a call to the service is necessary before updating the display
    # (for example when the dashboards list is modified)
    $scope.refreshDashboards = () ->
      $scope.dashboardsList = ImpacDashboardingSvc.getDashboards()
      $scope.currentDhb = _.where($scope.dashboardsList, {id: $scope.currentDhbId})[0]
      if $scope.currentDhb != undefined
        $scope.currentDhb.organizationsNames = _.map($scope.currentDhb.data_sources, (org) ->
          org.label
        ).join(", ")
        $scope.widgetsList = $scope.currentDhb.widgets_templates
      $scope.setDisplay()


    # TODO? Move to service
    $scope.getCurrentDhbWidgetsNumber = ->
      if $scope.currentDhb && $scope.currentDhb.widgets
        return $scope.currentDhb.widgets.length
      else
        return 0

    # TODO? Move to service
    # Allows to refresh the display when a widget is deleted
    $scope.$watch $scope.getCurrentDhbWidgetsNumber, (result) ->
      $scope.setDisplay()

    # When there is no need to call the service again before updating the display
    # (for example, when widgets are modified)
    $scope.setDisplay = () ->
      aDashboardExists = $scope.currentDhbId?
      severalDashboardsExist = aDashboardExists && $scope.dashboardsList.length > 1
      if (aDashboardExists)
        aWidgetExist = $scope.currentDhb.widgets.length > 0
      else
        aWidgetExist = false

      # Permissions and 'show helpers'
      # dashboard name
      $scope.showDashboardsList = false
      # buttons
      $scope.showCreateDhb = aDashboardExists
      $scope.showDeleteDhb = aDashboardExists
      $scope.showCreateWidget = aDashboardExists
      # messages      
      $scope.showChooseDhbMsg = !aDashboardExists
      $scope.showNoWidgetsMsg = aDashboardExists && !aWidgetExist
      #widgets
      $scope.canManageWidgets = true


    # Used by the dashboard selector (top of the page)
    $scope.selectDashboard = (dhbId) ->
      $scope.currentDhbId = dhbId
      $scope.refreshDashboards()

    #====================================
    # Dashboard management - widget selector
    #==================================== 

    $scope.selectedCategory = 'accounts'
    $scope.isCategorySelected = (aCatName) ->
      if $scope.selectedCategory? && aCatName?
        return $scope.selectedCategory == aCatName
      else
        return false

    $scope.getSelectedCategoryName = ->
      if $scope.selectedCategory?
        switch $scope.selectedCategory
          when 'accounts'
            return 'Accounting'
          when 'invoices'
            return 'Invoicing'
          when 'hr'
            return 'HR / Payroll'
          when 'sales'
            return 'Sales'
          else
            return false
      else
        return false

    $scope.getSelectedCategoryTop = ->
      if $scope.selectedCategory?
        switch $scope.selectedCategory
          when 'accounts'
            return {top: '33px'}
          when 'invoices'
            return {top: '64px'}
          when 'hr'
            return {top: '95px'}
          when 'sales'
            return {top: '126px'}
          else
            return {top: '9999999px'}
      else
        return false

    $scope.getWidgetsForSelectedCategory = ->
      if $scope.selectedCategory? && $scope.widgetsList?
        return _.select $scope.widgetsList, (aWidgetTemplate) ->
          aWidgetTemplate.path.split('/')[0] == $scope.selectedCategory
      else
        return []

    $scope.addWidget = (widgetPath, widgetMetadata=null) ->
      params = {widget_category: widgetPath}
      if widgetMetadata?
        angular.extend(params, {metadata: widgetMetadata})
      angular.element('#widget-selector').css('cursor', 'progress')
      angular.element('#widget-selector .top-container .row.lines p').css('cursor', 'progress')
      ImpacDashboardingSvc.widgets.create($scope.currentDhbId,params).then(
        () ->
          $scope.errors = ''
          angular.element('#widget-selector').css('cursor', 'auto')
          angular.element('#widget-selector .top-container .row.lines p').css('cursor', 'pointer')
          angular.element('#widget-selector .badge.confirmation').fadeTo(250,1)
          $timeout ->
            angular.element('#widget-selector .badge.confirmation').fadeTo(700,0)
          ,4000
        , (errors) ->
          $scope.errors = Utilities.processRailsError(errors)
          angular.element('#widget-selector').css('cursor', 'auto')
          angular.element('#widget-selector .top-container .row.lines p').css('cursor', 'pointer')
      ).finally( ->
        $scope.setDisplay()
      )


    #====================================
    # Dashboard management - Modals
    #====================================  

    # Would it be possible to manage modals in a separate module ? 
    # -> Check maestrano-modal (modal-svc) for further update
    $scope.modal = {}
    $scope.modal.addWidget = modalAddWidget = $scope.$new(true)
    $scope.modal.createDashboard = modalCreateDashboard = $scope.$new(true)
    $scope.modal.deleteDashboard = modalDeleteDashboard = $scope.$new(true)


    # Modal Add Widget
    modalAddWidget.config = {
      action: 'add',
      instance: {
        backdrop: 'static',
        templateUrl: TemplatePath['mno_enterprise/impac/modals/add.html'],
        size: 'md',
        windowClass: 'inverse',
        scope: modalAddWidget
      }
    }

    modalAddWidget.open = ->
      self = modalAddWidget
      self.model = {}
      self.widgetsList = $scope.widgetsList
      self.loadingGif = $scope.assetPath['mno_enterprise/loader-32x32-bg-inverse.gif']
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false

    modalAddWidget.close = ->
      modalAddWidget.$instance.close()

    modalAddWidget.proceed = (widgetPath, widgetMetadata=null) ->
      self = modalAddWidget
      self.isLoading = true
      params = {widget_category: widgetPath}
      if widgetMetadata?
        angular.extend(params, {metadata: widgetMetadata})
      ImpacDashboardingSvc.widgets.create($scope.currentDhbId,params).then(
        () ->
          self.errors = ''
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.setDisplay())
    
    modalAddWidget.isAccount = (aPath) ->
      if aPath.match(/accounts/)
        true
      else
        false
    
    modalAddWidget.isInvoices = (aPath) ->
      if aPath.match(/invoices/)
        true
      else
        false

    # Modal Create Dashboard
    modalCreateDashboard.config = {
      action: 'create',
      instance: {
        backdrop: 'static',
        templateUrl: TemplatePath['mno_enterprise/impac/modals/create.html'],
        size: 'md',
        windowClass: 'inverse connec-analytics-modal',
        scope: modalCreateDashboard
      }
    }

    modalCreateDashboard.open = ->
      self = modalCreateDashboard
      self.model = { name: null }
      self.organizations = angular.copy($scope.user.organizations)
      self.currentOrganization = _.findWhere(self.organizations,{id: DhbOrganizationSvc.getId()})
      self.selectMode('single')
      self.loadingGif = AssetPath['mno_enterprise/loader-32x32-bg-inverse.gif']
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false

    modalCreateDashboard.close = ->
      modalCreateDashboard.$instance.close()

    modalCreateDashboard.proceed = ->
      self = modalCreateDashboard
      self.isLoading = true
      dashboard = { name: self.model.name }
      
      # Add organizations if multi company dashboard
      if self.mode == 'multi'
        organizations = _.select(self.organizations, (o) -> o.$selected )
      else
        organizations = [ { id: DhbOrganizationSvc.getId() } ]
      
      if organizations.length > 0
        dashboard.organization_ids = _.pluck(organizations, 'id')
      
      ImpacDashboardingSvc.dashboards.create(dashboard).then(
        (dashboard) ->
          self.errors = ''
          $scope.currentDhbId = dashboard.id
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.refreshDashboards())
      
    modalCreateDashboard.proceedDisabled = ->
      self = modalCreateDashboard
      selectedCompanies = _.select(self.organizations, (o) -> o.$selected)
      
      # Check that dashboard has a name
      additional_condition = !self.model.name || self.model.name == ''
      
      # Check that some companies have been selected
      additional_condition ||= selectedCompanies.length == 0
      
      # Check that user can access the analytics data for this company
      additional_condition ||= _.select(selectedCompanies, (o) -> self.canAccessAnalyticsData(o)).length == 0
      
      return self.isLoading || additional_condition

    modalCreateDashboard.btnBlassFor = (mode) ->
      self = modalCreateDashboard
      if mode == self.mode
        "btn btn-sm btn-warning active"
      else
        "btn btn-sm btn-default"
    
    modalCreateDashboard.selectMode = (mode) ->
      self = modalCreateDashboard
      _.each(self.organizations, (o) -> o.$selected = false)
      self.currentOrganization.$selected = (mode == 'single')
      self.mode = mode
    
    modalCreateDashboard.isSelectOrganizationShown = ->
      modalCreateDashboard.mode == 'multi'
    
    modalCreateDashboard.isCurrentOrganizationShown = ->
      modalCreateDashboard.mode == 'single'
    
    modalCreateDashboard.canAccessAnalyticsForCurrentOrganization = ->
      self = modalCreateDashboard
      self.canAccessAnalyticsData(self.currentOrganization)
    
    modalCreateDashboard.isMultiCompanyAvailable = ->
      modalCreateDashboard.organizations.length > 1

    modalCreateDashboard.canAccessAnalyticsData = (organization) ->
      organization.current_user_role && (
        organization.current_user_role == "Super Admin" ||
        organization.current_user_role == "Admin"
      )

    # Modal Delete Dashboard
    modalDeleteDashboard.config = {
      action: 'delete',
      instance: {
        backdrop: 'static',
        templateUrl: TemplatePath['mno_enterprise/impac/modals/delete.html'],
        size: 'md',
        windowClass: 'inverse',
        scope: modalDeleteDashboard
      }
    }

    modalDeleteDashboard.open = ->
      self = modalDeleteDashboard
      self.loadingGif = $scope.assetPath['mno_enterprise/loader-32x32-bg-inverse.gif']
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false

    modalDeleteDashboard.close = ->
      modalDeleteDashboard.$instance.close()

    modalDeleteDashboard.proceed = ->
      self = modalDeleteDashboard
      self.isLoading = true
        
      ImpacDashboardingSvc.dashboards.delete($scope.currentDhbId).then(
        () ->
          self.errors = ''
          $scope.currentDhbId = ImpacDashboardingSvc.getId()
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.refreshDashboards())
    

    #====================================
    # Drag & Drop management
    #====================================      

    $scope.sortableOptions = {
      # When the widget is dropped
      stop: saveDashboard = ->
        data = { widgets_order: _.pluck($scope.currentDhb.widgets,'id') }
        ImpacDashboardingSvc.dashboards.update($scope.currentDhbId,data,false)
      
      # When the widget is starting to be dragged
      ,start: updatePlaceHolderSize = (e, widget) ->
        # width-1 to avoid return to line (succession of float left divs...)
        widget.placeholder.css("width",widget.item.width() - 1)
        widget.placeholder.css("height",widget.item.height())

        # # Determining height of the placeholder
        # maxHeight=0
        # _.each e.currentTarget.children, (w) ->
        #   if (w.className != 'placeHolderBox')
        #     height = w.clientHeight
        #     if height > maxHeight
        #       maxHeight = height
        # cssHeight = ''
        # cssHeight = cssHeight.concat(maxHeight)
        # cssHeight = cssHeight.concat('px')
        # _.each e.currentTarget.children, (w) ->
        #   w.style.height = cssHeight
        #   w.style.clear = 'none'


      # Options
      ,cursorAt: {left: 100, top: 20}
      ,opacity: 0.5
      ,delay: 150
      ,tolerance: 'pointer'
      ,placeholder: "placeHolderBox"
      ,cursor: "move"
      ,revert: 250
      }

])

module.directive('impacIndex', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/impac/impac-index.html'],
      controller: 'ImpacIndexCtrl'
    }
])