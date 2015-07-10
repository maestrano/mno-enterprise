module = angular.module('maestrano.components.mno-loading-lounge',['maestrano.assets'])

#============================================
# Component 'LoadingLounge'
# --
# Standalone component used on the app loading
# page
#============================================
module.controller('MnoLoadingLoungeCtrl',[
  '$scope', '$http', 'AssetPath', 'Utilities', '$window', '$timeout'
  ($scope, $http, AssetPath, Utilities, $window, $timeout) ->

    #==========================
    # Init
    #==========================
    #$scope.appInstance = appInstance = new AppInstances($scope.mnoLoadingLounge())
    $scope.appInstance = appInstance = $scope.mnoLoadingLounge()
    appInstanceId = $scope.mnoLoadingLounge().id

    $scope.redirectionCounter = 10 #seconds
    $scope.scheduler = null
    $scope.redirectScheduler = null


    #==========================
    # Helpers
    #==========================
    currentStatus = $scope.currentStatus = () ->
      if appInstance.id
        if appInstance.errors && appInstance.errors.length > 0
          'errors'
        else if appInstance.status == 'running' && appInstance.is_online
          'online'
        else if (appInstance.status == 'provisioning' || appInstance.status == 'staged')
          'creating'
        else if appInstance.status == 'updating'
          'updating'
        else
          # starting/stopping
          # Note: If 'stopping' and no errors it means that a start has been
          # successfully requested
          'loading'
      else
        'not_found'

    $scope.errorMessages = () ->
      Utilities.processRailsError(appInstance.errors)

    $scope.isProgressBarShown = () ->
      currentStatus() == 'creating' || currentStatus() == 'loading'

    # Return the action progression in percent
    # unit
    # Eg. $scope.progressBarPercent() -> 95%
    $scope.progressBarPercent = () ->
      # Get out of there if the bar is not shown
      if !$scope.isProgressBarShown()
        return 0

      # Get the relevant status from an actionProgress
      # point of view
      realStatus = appInstance.status
      realStatus = 'provisioning' if realStatus == 'staged'
      realStatus = 'starting' if realStatus == 'restarting'

      # Get the maxDuration (seconds) for the current action
      # In case the app is stopping we consider that a start
      # has been requested. Therefore we add the starting
      # time on top of it
      maxDuration = appInstance.durations[realStatus]
      maxDuration += appInstance.durations['starting'] if realStatus == 'stopping'

      # Get the referenceField based on
      # the action being performed
      referenceField = {
        'provisioning': 'created_at',
        'starting': 'started_at',
        'stopping': 'stopped_at',
        }[realStatus]

      # Get the action elapsed time in seconds
      startTime = new Date(appInstance[referenceField])
      endTime = new Date(appInstance.server_time)
      elapsedTime = (endTime.getTime() - startTime.getTime()) / 1000

      # Calculate the percentage
      # Max value is 95% / Min value is 5%
      # Cesar: test should prevent division by 0 and display of "Nan%"
      if (maxDuration > 0)
        percent = Math.round((elapsedTime / maxDuration)*100)
        percent = Math.min(percent, 95)
        percent = Math.max(percent, 5)
      else
        percent = 95

      percent = "#{percent}%"
      return percent

    reloadAppInstance = (_appInstance)->
      q = $http.get($window.location.pathname)
      q.then(
        (success) ->
          angular.copy(success.data,_appInstance)
      )
      return q

    $scope.startAutoRefresh = () ->
      intervalMilliSec = 15 * 1000
      # Make sure we cancel any previous
      # scheduler first
      if $scope.scheduler?
        $timeout.cancel($scope.scheduler)

      # Configure the scheduler
      $scope.scheduler = $timeout(->
        reloadAppInstance(appInstance)
        $scope.startAutoRefresh()
      ,intervalMilliSec)

    $scope.stopAutoRefresh = () ->
      if $scope.scheduler?
        $timeout.cancel($scope.scheduler)

    $scope.redirectUrl = ->
      "/mnoe/launch/#{appInstance.uid}"

    $scope.performRedirection = () ->
      # Then reload the page
      window.location = $scope.redirectUrl()

    $scope.startRedirectCountdown = () ->
      intervalMilliSec = 1 * 1000
      # Make sure we cancel any previous
      # scheduler first
      if $scope.redirectScheduler?
        $timeout.cancel($scope.redirectScheduler)

      # Configure the scheduler
      $scope.redirectScheduler = $timeout(->
        $scope.redirectionCounter -= 1
        $scope.startRedirectCountdown() if $scope.redirectionCounter > 0
        $scope.performRedirection() if $scope.redirectionCounter == 0
      ,intervalMilliSec)


    $scope.stopRedirectCountdown = () ->
      if $scope.redirectScheduler?
        $timeout.cancel($scope.redirectScheduler)
        $scope.redirectionCounter = 10

    #==========================
    # Watchers
    #==========================
    # Watch status
    $scope.$watch(
      (-> currentStatus())
      ,(status)->
        # Enable appInstance refresh?
        if status == 'loading' || status == 'creating' || status == 'updating'
          $scope.startAutoRefresh() unless $scope.scheduler
        else
          $scope.stopAutoRefresh() if $scope.scheduler

        # Enable redirection counter?
        if status == 'online'
          $scope.startRedirectCountdown() unless $scope.redirectScheduler
        else
          $scope.stopRedirectCountdown() if $scope.redirectScheduler
    )

])

module.directive('mnoLoadingLounge', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'AE',
      scope: {
        mnoLoadingLounge: '&'
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/loading_lounge.html'],
      controller: 'MnoLoadingLoungeCtrl'
    }
])
