module = angular.module('maestrano.impac.widget',['maestrano.assets'])

module.controller('ImpacWidgetCtrl', [
  '$scope', '$timeout', 'ImpacDashboardingSvc', 'TemplatePath', 'AssetPath',
  ($scope, $timeout, ImpacDashboardingSvc, TemplatePath, AssetPath) ->

    # ---------------------------------------------------------
    # ### Widget template scope
    # ---------------------------------------------------------

    $scope.loaderImage = AssetPath['mno_enterprise/loader-32x32-bg-inverse.gif']

    # ---------------------------------------------------------
    # ### Toolbox
    # ---------------------------------------------------------

    # angular.merge doesn't exist in angular 1.2...
    extendDeep = (dst, src) ->
      angular.forEach src, (value, key) ->
        if dst[key] and dst[key].constructor and dst[key].constructor is Object
          extendDeep dst[key], value
        else
          dst[key] = value

    # ---------------------------------------------------------
    # ### Widget object management
    # ---------------------------------------------------------

    # Initialization
    w = $scope.widget || {}
    w.parentDashboard ||= $scope.parentDashboard
    w.settings = []
    w.isLoading = true
    # TODO
    w.hasEditAbility = true
    w.hasDeleteAbility = true

    # Retrieve the widget content from Impac! and initialize the widget from it
    w.loadContent = (waitForLoad=true) ->
      w.isLoading = true if waitForLoad
      ImpacDashboardingSvc.widgets.show(w).then(
        (updatedWidget) ->
          updatedWidget.content ||= {}
          updatedWidget.originalName = updatedWidget.name
          angular.extend(w,updatedWidget)
          
          # triggers the initialization of the widget's specific params (defined in the widget specific controller)
          w.initContext()
          # triggers the initialization of all the widget's settings
          w.initSettings(waitForLoad)
          # formats the widget's chart data when needed
          w.format() if angular.isDefined(w.format)

          w.isLoading = false if waitForLoad
        ,(errors) ->
          w.isLoading = false if waitForLoad
      )

    # Initialize all the settings of the widget
    w.initSettings = (waitForLoad=true) ->
      angular.forEach(w.settings, (setting) ->
        setting.initialize()
      )
      # For discreet metadata updates, we don't want to force editMode to be false
      # example: changing hist mode
      w.isEditMode = false if waitForLoad
      return true

    # Retrieve all the widgets settings, build the new metadata parameter, and call pushMetadata
    w.updateSettings = (waitForLoad=true) ->
      meta = {}
      angular.forEach(w.settings, (setting) ->
        extendDeep(meta,setting.toMetadata())
      )
      pushMetadata(meta, waitForLoad) if !_.isEmpty(meta)
      return true

    # Push a new metadata parameter associated to the widget to Impac! and reload the widget content
    # should be considered as a private function: if it is called separately with only one setting, 
    # the other settings will be reinitialized...
    pushMetadata = (newMetadata, waitForLoad = true) ->
      w.isLoading = true if waitForLoad
      data = { metadata: newMetadata }
      if !_.isEmpty(newMetadata)
        ImpacDashboardingSvc.widgets.update(w,data).then(
          (success) ->
            angular.extend(w,success.data)
            # TODO: remove call to loadContent once the charts are not retrieved from Impac! anymore
            w.loadContent(waitForLoad)
          , (errors) ->
            w.errors = Utilities.processRailsError(errors)
            w.isLoading = false if waitForLoad
        )
      else
        w.isLoading = false if waitForLoad
])


module.directive('impacWidget', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentDashboard: '=',
      widget: '='
    },
    controller: 'ImpacWidgetCtrl',
    link: (scope, element) ->
      # DEFINITION of TEMPLATE and CLASS
      # All templates are defined by the first two elements of the corresponding path
      # the "width" (number of bootstrap columns) is stored in the widget model
      splittedPath = angular.copy(scope.widget.category).replace("_","-").split("/").splice(0,2)
      templateElems = "mno_enterprise/impac/widgets/".concat(splittedPath.join("-"))
      scope.templateUrl = TemplatePath[templateElems.concat(".html")]

      element.addClass("col-md-#{scope.widget.width}")

    ,template: '<div ng-include="templateUrl"></div>'
  }
])