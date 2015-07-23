module = angular.module('maestrano.impac.widgets.settings.organizations',['maestrano.assets'])

module.controller('WidgetSettingOrganizationsCtrl', ['$scope', ($scope) ->

  w = $scope.parentWidget

  $scope.dashboardOrganizations = w.parentDashboard.data_sources
  w.selectedOrganizations = {}

  $scope.isOrganizationSelected = (orgUid) ->
    !!w.selectedOrganizations[orgUid]

  $scope.toogleSelectOrganization = (orgUid) ->
    w.selectedOrganizations[orgUid] = !w.selectedOrganizations[orgUid]

  # What will be passed to parentWidget
  setting = {}
  setting.key = "organizations"
  setting.isInitialized = false

  # initialization of selected organizations
  setting.initialize = ->
    if w.content && w.content.organizations
      angular.forEach(w.content.organizations, (orgUid) ->
        w.selectedOrganizations[orgUid] = true
      )
      setting.isInitialized = true

  setting.toMetadata = ->
    newOrganizations = _.compact(_.map(w.selectedOrganizations, (checked,uid) ->
      uid if checked
    ))
    return { organization_ids: newOrganizations }

  w.settings ||= []
  w.settings.push(setting)
])

module.directive('widgetSettingOrganizations', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/settings/organizations.html'],
    controller: 'WidgetSettingOrganizationsCtrl'
  }
])