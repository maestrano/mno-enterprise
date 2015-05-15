module = angular.module('maestrano.impac.widgets.settings.chart-filters',['maestrano.assets'])

module.controller('WidgetSettingChartFiltersCtrl', ['$scope', ($scope) ->

  w = $scope.parentWidget

  setting = {}
  setting.key = "chart-filters"
  setting.isInitialized = false

  setting.initialize = ->
    if w.content.chart_filter? && $scope.filterCriteria = w.content.chart_filter['criteria']
      $scope.maxEntities = w.content.chart_filter['max'].to_i || w.content.entities.length
      if $scope.filterCriteria == "customersNumber"
        $scope.filterValueInv = 80
        $scope.filterValueCust = w.content.chart_filter['value']
      else
        $scope.filterValueInv = w.content.chart_filter['value']
        $scope.filterValueCust = Math.round($scope.maxEntities/2)
      setting.isInitialized = true

  setting.toMetadata = ->
    if w.content.chart_filter?
      if $scope.filterCriteria == "invoicedAmount"
        filterValue = $scope.filterValueInv
      else
        filterValue = $scope.filterValueCust
      return { chart_filter: {criteria: $scope.filterCriteria, value: filterValue, max: $scope.maxEntities} }
    else
      return {}

  w.settings ||= []
  w.settings.push(setting)
])

module.directive('widgetSettingChartFilters', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/settings/chart-filters.html'],
    controller: 'WidgetSettingChartFiltersCtrl'
  }
])