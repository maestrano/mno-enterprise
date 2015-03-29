module = angular.module('maestrano.dashboard.dashboard-apps-list',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardAppsListCtrl',[
  '$scope','DashboardAppsDocument','DashboardAppInstance','AssetPath','AppsListHelper','$interval','$q','DhbOrganizationSvc','MsgBus',
  ($scope, DashboardAppsDocument, DashboardAppInstance, AssetPath, AppsListHelper, $interval, $q, DhbOrganizationSvc, MsgBus) ->
    $scope.blink = { value: 'neutral' }

    #====================================
    # Pre-Initialization
    #====================================
    $scope.loading = true
    $scope.starWizardModal = { value:false }
    MsgBus.publish('starWizardModal',$scope.starWizardModal)

    $scope.openStarWizard = ->
      $scope.starWizardModal.value = true

    $scope.originalApps = []

    #====================================
    # Scope Management
    #====================================
    init = () ->
      # Scope initialization
      $scope.displayOptions = {}
      $scope.displayCustomInfo = {}
      $scope.helper = {}
      $scope.assetPath = AssetPath
      $scope.appsListHelper = AppsListHelper.new()
      can = DhbOrganizationSvc.can
      angular.copy(DashboardAppsDocument.data,$scope.originalApps)


      # ----------------------------------------------------------
      # Permissions helper
      # ----------------------------------------------------------
      $scope.helper.displayCogwheel = ->
        can.update.appInstance()

      $scope.helper.canRestartApp = ->
        can.update.appInstance()

      $scope.helper.canRenameApp = ->
        can.update.appInstance()

      $scope.helper.canDeleteApp = ->
        can.destroy.appInstance()

      $scope.helper.canChangePlanApp = (app)->
        app.stack == 'cube' && can.update.appInstance()

      $scope.helper.displayBootstrapWizard = ->
        can.update.appInstance()

      $scope.apps = DashboardAppsDocument.data

      # ----------------------------------------------------------
      # Restart app
      # ----------------------------------------------------------
      $scope.restartApp = { loading: false }
      $scope.restartApp.perform = (id) ->
        $scope.restartApp.loading = true
        DashboardAppInstance.restart(id).then(
          (success) ->
            $scope.restartApp.loading = false
          (error) ->
            $scope.restartApp.loading = false
        )

      $scope.updateAppName = (app) ->
        origApp = $scope.originalApps["app_instance_#{app.id}"]
        if app.name.length == 0
          app.name = origApp.name
        else
          DashboardAppInstance.updateName(app.id,app.name).then(
            (->)
              origApp.name = app.name
            , ->
              app.name = origApp.name
          )

    # ----------------------------------------------------------
    # Little trick to create 'blinking' effect
    # (used for the status of the apps)
    # ----------------------------------------------------------
    blink = ->
      if $scope.blink.value == '' then $scope.blink.value = 'neutral'
      else $scope.blink.value = ''
    $interval((-> blink()),500)

    $scope.shouldBlink = (status) ->
      _.contains([
        'starting',
        'restarting',
        'stopping',
        'terminating',
        'upgrading',
        'downgrading',
      ],status)


    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DashboardAppsDocument.getId, (val) ->
      $scope.loading = true
      if val?
        DashboardAppsDocument.load(val).then () ->
          init()


])

module.directive('dashboardAppsList', ['TemplatePath', (TemplatePath) ->
  console.log(TemplatePath['mno_enterprise/dashboard/apps_list.html'])
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/apps_list.html'],
      controller: 'DashboardAppsListCtrl'
    }
])
