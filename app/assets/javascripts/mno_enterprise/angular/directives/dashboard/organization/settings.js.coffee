module = angular.module('maestrano.dashboard.dashboard-organization-settings',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationSettingsCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'Utilities','AssetPath'
  ($scope, $window, DhbOrganizationSvc, Utilities, AssetPath) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.model = {}
    $scope.origModel = {}
    $scope.forms = {}
    
    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    $scope.initialize = (organization) ->
      angular.copy(organization,$scope.model)
      angular.copy(organization,$scope.origModel)
      $scope.isLoading = false
    
    # Save the current state of the credit card
    $scope.save = ->
      $scope.isLoading = true
      DhbOrganizationSvc.organization.update($scope.model).then(
        (organization) ->
          $scope.errors = ''
          angular.copy(organization,$scope.model)
          angular.copy(organization,$scope.origModel)
        , (errors) ->
          $scope.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.isLoading = false)
    
    # Cancel the temporary changes made by the
    # user
    $scope.cancel = ->
      angular.copy($scope.origModel,$scope.model)
      $scope.errors = ''
    
    # Check if the user has started editing the
    # form
    $scope.isChanged = ->
      !angular.equals($scope.model,$scope.origModel)
    
    # Check whether we should display the cancel
    # button or not
    $scope.isCancelShown = ->
      $scope.isChanged()
    
    # Should we enable the save button
    $scope.isSaveEnabled = ->
      f = $scope.forms
      $scope.isChanged() && f.settings.$valid
    
    # Return the class to add to the btn
    # based on soa_enabled
    $scope.connecBtnClassFor = (action) ->
      if action == 'enable'
        return ( $scope.model.soa_enabled && 'btn-warning')
      else
       return ( !$scope.model.soa_enabled && 'btn-warning')
    
    # Action to be perform when user clicks on 'enable'
    # or 'disable'
    $scope.connecBtnClickOn = (action) ->
      $scope.model.soa_enabled = (action == 'enable')
    
    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      $scope.isLoading = true
      if val?
        DhbOrganizationSvc.load().then (organization)->
          $scope.initialize(organization.organization)
])

module.directive('dashboardOrganizationSettings', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['dashboard/organization/settings.html'],
      controller: 'DashboardOrganizationSettingsCtrl'
    }
])